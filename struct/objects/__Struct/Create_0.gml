/// @description Set Variables Here

#region !!DO NOT MODIFY!! singleton and instance set up

//We will use a singleton pattern to make sure there is only one object "__Struct" that serves as the master.
//	As we create structs, we will make clones of the __Struct object to serve as "structs", but they will
//	know that they are not the master __Struct object, so they will only contain a few default variables
//	and will perform no step/draw actions.  These objects are all deactivated at creation time to limit their
//	CPU footprint.  The master __Struct object will reactivate them when changing rooms, then deactive them
//	once the new room is open.
__struct_is_master = true;

//Set every __Struct object to persistent so it can move between rooms, and turn off visibility just to be
//	safe.  Setting this IS redundant, but will have such a tiny footprint it shouldn't matter.
persistent = true;
visible = false;

//If this is not the original __Struct object...
//
//	__struct_is_master -> this is not the master __Struct object that will handle memory management
//	__struct_owner -> this will hold the instance ID of the object that creates this __Struct.  We
//						later use this for memory management, as we will destroy orphaned __Structs
//	__struct_variables -> this array will hold the variables that the "struct" will contain
//
//	finally, we will deactivate this __Struct object so GameMaker doesn't attempt to run any events
//	for it, then exit the creation script.
if (instance_number(object_index) > 1) {
	__struct_is_master = false;
	__struct_owner = noone;
	__struct_variables = [];
	instance_deactivate_object(self.id);
	exit;
}
#endregion

//Everything below here only gets run at the creation of the master __Struct object

#region EDIT VARIABLES HERE
//Should __Struct automatically manage its memory usage?
//	Default: true
//	If set to false, you will need to routinely run __struct_memory_cleanup()
//		or you could end up with potentially thousands of objects in memory.
__struct_automatic_memory_management = true;

//How often the cleanup process will run (in seconds).
//	Default: 300 (seconds)
__struct_cleanup_interval = 300;

//Add randomness to the cleanup process (in seconds).
//	If the cleanup interval is set to 300 seconds, and the cleanup random
//	range is set to 10 seconds, then the cleanup will occur randomly between
//	(300 - 10) and (300 + 10) seconds.
//	Default: 10 (seconds)
//	Set to 0 to remove randomness
__struct_cleanup_random_range = 10;

//If debug mode is enabled, you will get verbose output from the script, including
//	game breaking warnings.
//	Default: true
//	Set to false before packaging game for release
__struct_debug_mode = true;
#endregion

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!Don't edit stuff below here or things will break!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//If the cleanup time could end up being negative we will notify the developer
//	and disable automatic memory management.  We will also go ahead and raise
//	the cleanup interval to be (random_range + 1) seconds so if memory cleanup
//	is run manually we won't get an error.
if(__struct_cleanup_interval <= __struct_cleanup_random_range) {
	if(__struct_debug_mode) {
		show_debug_message("__Struct: WARN -> __struct_cleanup_interval is lower value than __struct_cleanup_random_range.");
		show_debug_message("	Disabling Automatic Memory Management and setting __struct_cleanup_interval to be one (1)");
		show_debug_message("	second higher than the __struct_cleanup_random_range. See __Struct -> Create -> Line 68.");
	}
	__struct_automatic_memory_management = false;
	__struct_cleanup_interval = __struct_cleanup_random_range + 1;
}

//This is used for checking to see if we are running Room Start for the first time
//	in game execution.  This is specifically used to notify the developer if they
//	tried to switch rooms without using the custom room switching functions that
//	are provided with __Struct
__struct_first_run = true;

//This will hold a list of instance IDs of all non-master __Struct objects.  We will
//	use this in the memory management process to identify orphaned __Structs and
//	destroy them.
__struct_nodes = [];

//We are going to set the instance ID of this master __Struct object to a global
//	so we can find it and read from its variables easily and quickly.
globalvar __struct_master;
__struct_master = self.id;

//This variable is used to identify when the room has been switched with (or without)
//	the use of the custom _room_goto* scripts.
__struct_room_switch = false;


//The __struct_layer is created at Room Start and all non-master __Struct object instances
//	are placed on this layer.  By placing all of the instances on a shared layer we can
//	easily (de)activate all of them at the same time.
__struct_layer = layer_get_id("__Struct");
if(!layer_exists(__struct_layer)) {
	__struct_layer = layer_create(15999,"__Struct");
	layer_set_visible(__struct_layer, false);
}

//If automatic memory management is enabled, we will set up the Alarm 0 event to run in the
//	specified time.  This Alarm event will destroy orphaned __Struct object instances.
if(__struct_automatic_memory_management) {
	alarm[0] = room_speed * (__struct_cleanup_interval - irandom_range(-__struct_cleanup_random_range,__struct_cleanup_random_range));
}