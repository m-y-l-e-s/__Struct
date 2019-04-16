/// @function __struct_memory_cleanup()
/// @description Perform memory management on __Struct object instances.

//See __Struct -> User Event 0 - README - MANUAL for explanation
//	of how __Struct works, and why this script is necessary.

//Set the master __Struct object instance cleanup alarm to go off
//	next frame.
__struct_master.alarm[0] = 1;