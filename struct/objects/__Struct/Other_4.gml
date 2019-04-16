/// @description Process __Structs

if(__struct_is_master) {
	//If the room has switched without using the custom _room_goto* functions and we are showing
	//	debug messages we should let the user know that they have messed up.  If they failed to
	//	use the custom scripts all of their __Struct objects will be lost, so the game will
	//	probably crash immediately as they will access non-existent variables.
	if(!__struct_room_switch && __struct_debug_mode && !__struct_first_run) {
		show_debug_message("__Struct: ERROR -> Room has changed without using custom room change scripts.");
		show_debug_message("	Please use the _room_goto* scripts provided with __Struct to change rooms.");
		show_debug_message("	This is necessary due to how __Struct objects are deactivated during play, then");
		show_debug_message("	reactivated as the room changes.  Reactivation needs to occur just prior to the");
		show_debug_message("	room change being initiated.  Your game will most likely now crash.");
	}
	
	//We set the first run to false so we know that we aren't in the Room Start event of the
	//	very first room of the game.
	__struct_first_run = false;
}

//If we have switched rooms we will need to create a new layer for all of the __Struct object
//	instances to live on.
if(__struct_master.__struct_room_switch) {
	__struct_master.__struct_layer = layer_get_id("__Struct");
	if(!layer_exists(__struct_master.__struct_layer)) {
		__struct_master.__struct_layer = layer_create(15999,"__Struct");
		layer_set_visible(__struct_master.__struct_layer, false);
	}
	__struct_master.__struct_room_switch = false;
}

//If this is a non-master __Struct object running this Room Start event, move it to the new
//	__struct_layer and deactivate it.
if(!__struct_is_master) {
	layer = __struct_master.__struct_layer;
	instance_deactivate_object(self.id);
}