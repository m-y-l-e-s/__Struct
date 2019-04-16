/// @function new_struct(struct_variables[0 .. X],default_values)
/// @description Create a new struct object and assign variables.
/// @param {string} struct_variables Variable names declared for this 'struct' using argument[0 .. 99].
/// @param {array} default_values (Optional) Array of values that you want to assign at creation time.

//If the user has provided an array with default values as their final argument we will
//	store a reference of them for later.
var __struct_has_default_values = false;

if(is_array(argument[argument_count-1])) {
	var __struct_default_values = argument[argument_count-1];
	__struct_has_default_values = true;
}

//Create a new instance of the __Struct object on the __struct_layer.
var __struct_new_instance = instance_create_layer(0,0,__struct_master.__struct_layer,__Struct);

//Set the __struct_owner variable of this object to the instance that is running this script.
__struct_new_instance.__struct_owner = self.id;

//If they have provided us with default values we will create each variable
//	in the new __Struct object instance, then assign it.
//
//	We will then construct an array called __struct_variables and populate it
//		with the variable strings that were provided.  This is mostly for debug
//		purposes when you are developing your game.
if(__struct_has_default_values) {
	for(var __struct_i = 0; __struct_i < (argument_count - 1); __struct_i++) {
		variable_instance_set(__struct_new_instance,string(argument[__struct_i]),__struct_default_values[__struct_i]);
		__struct_new_instance.__struct_variables[@ __struct_i] = string(argument[__struct_i]);
	}
} else {
	//If there are no default values we will create each variable in the new
	//	__struct object instance and set them all to -1.
	for(var __struct_i = 0; __struct_i < (argument_count); __struct_i++) {
		variable_instance_set(__struct_new_instance,string(argument[__struct_i]),-1);
		__struct_new_instance.__struct_variables[@ __struct_i] = string(argument[__struct_i]);
	}
}

//Add this new __Struct object instance ID to the end of the master __Struct
//	object's __struct_nodes array for memory management, then return the
//	instance ID of the new __Struct object instance.
__struct_master.__struct_nodes[@ array_length_1d(__struct_master.__struct_nodes)] = __struct_new_instance;
return __struct_new_instance;