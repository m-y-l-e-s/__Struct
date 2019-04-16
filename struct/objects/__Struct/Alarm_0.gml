/// @description Mem-Mgmt

//Turn off any existing alarm0 event, in case this was manually called.
alarm[0] = -1;

//This array will hold the nodes that are NOT orphaned, which we will set
//	to __struct_nodes once we have cleaned it.
var __struct_temp_array = [];

//Loop through the __struct_nodes...
for(var __struct_index = 0; __struct_index < array_length_1d(__struct_nodes); __struct_index++) {
	//If the the __Struct object instance exists, __struct_owner still exists,
	//	it has not been orphaned, so we add that __Struct instance to the temp array.
	if(instance_exists(__struct_nodes[__struct_index])) {
		if(instance_exists(__struct_nodes[__struct_index].__struct_owner)) {
			__struct_temp_array[@ array_length_1d(__struct_temp_array)] = __struct_nodes[__struct_index];
		} else {
			//If the __struct_owner no longer exists then this __Struct object instance
			//	has been orphaned, so we will destroy it.
			instance_destroy(__struct_nodes[__struct_index], false);
		}
	}
}

//Set the __struct_nodes array to the new list of non-orphaned __Struct object instances.
__struct_nodes = __struct_temp_array;

//If memory management is to occur automatically, go ahead and set Alarm[0] to run again.
if(__struct_automatic_memory_management) {
	alarm[0] = room_speed * (__struct_cleanup_interval - irandom_range(-__struct_cleanup_random_range,__struct_cleanup_random_range));
}