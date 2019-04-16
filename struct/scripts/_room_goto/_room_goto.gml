/// @function _room_goto(numb)
/// @description See manual reference for room_goto()
/// @param {int/room_name} numb The index of the room to go to.

//See __Struct -> User Event 0 - README - MANUAL for explanation
//	of how __Struct works, and why this script is necessary.

//Set the room switching flag in the master __Struct object.
__struct_master.__struct_room_switch = true;

//Activate all __Struct object instances on the __struct_layer.
instance_activate_layer(__struct_master.__struct_layer);

//Perform the normal room_goto()
//	Middle-click the function below to see its help page.
room_goto(argument[0]);