# GMS2 __Struct

**__Struct** is used to create the most true-to-form struct<sup>1</sup> data type possible<sup>2</sup>
in *GameMaker Studio 2*, in the most intuitive way I could think of.

<sup>1</sup> See https://en.wikipedia.org/wiki/Struct_(C_programming_language)

<sup>2</sup>This will, of course, be obsoleted when Lightweight Objects are added as per https://www.yoyogames.com/blog/514/gml-updates-in-2019

## TL:DR

 1. Place one copy of the __Struct object into your first room.
 2. Modify **__Struct** object -> *Create Event*
	```Game Maker Language
    (line 43) __struct_automatic_memory_management = true;
    (line 47) __struct_cleanup_interval = 300;
    (line 55) __struct_cleanup_random_range = 10;
    (line 61) __struct_debug_mode = true;
    ```
 3. In your code:
    ```Game Maker Language
    var inventory_slot = new_struct("is_free","name",[true,"Main Weapon"]);
    show_debug_message(string(inventory_slot.is_free));
    show_debug_message(string(inventory_slot.name));
    ```

## How do I use it?

### Creating Structs ###
Place one copy of the **__Struct** object into your first room.

In any object in your game you can now create a new struct like so:
```Game Maker Language
	var inventory_slot = new_struct("is_free","name");
```
Then, you can access the struct variables through your inventory_slot struct.
```Game Maker Language
	inventory_slot.is_free = true;
	inventory_slot.name = "Main Weapon";
```
Alternatively, you could also preset the default values like so:
```Game Maker Language
	var inventory_slot = new_struct("is_free","name",[true,"Main Weapon"]);
```
If the last argument provided to the *new_struct()* script is an array, it is
assumed to be the default values for the variables.  If no array is provided
all variables are initialised as -1.

Your created struct will by default contain 3 extra variables.

**DO NOT MODIFY THESE VARIABLES, THINGS WILL BREAK.**

	your_struct.__struct_is_master (bool)
		This is used to determine which __Struct object instance should be
		dealing with memory management.
		
	your_struct.__struct_owner (instance id)
		This hold the Instance ID of whatever created this struct.  This is
		used in memory management to determine if this __Struct has become
		orphaned and needs to be deleted.
		
	your_struct.__struct_variables (array)
		This is an array of the variables that you assigned to this struct
		when you created it with the new_struct() script.  It is just there
		for your convenience.

#### Detailed Use Example ####

*Object* -> obj_player

*Event* -> Create
```Game Maker Language	
		inventory = [];
		
		for(var i=0; i<5; i++) {
			inventory[i] = new_struct("is_free","name",[true,"slot empty"]);
		}
```		
*Event* -> Step
```Game Maker Language		
		if (place_meeting(x,y,obj_sword_pickup)) {
			for(var i=0; i<array_length_1d(inventory); i++) {
				if(inventory[i].is_free) {
					inventory[i].is_free = false;
					inventory[i].name = "Sword";
				}
			}
		}
```
    
The above code is an example of how you might use **__Struct** to create an
inventory system, with an example of how an item pickup could work.

### Changing Rooms ###

When changing rooms, you will need to use the provided custom room
change scripts:

	_room_goto_next();
	_room_goto_previous();
	_room_goto(numb);
    
#### Why do I need to use those scripts? ####

**__Struct** needs to run instance_activate_layer() before a room is changed
or all of your structs will be deleted.  The custom room switching scripts
are just thin wrappers around their respective functions.

### Memory Management ###

Finally, if you decide you want to manually manage the memory usage of
*__Struct* you will need to call:

	__struct_memory_cleanup();
	
This will destroy orphaned structs, freeing memory.  You should only
need to do this if you have disabled automatic memory management in

*__Struct* object -> **Create Event** ->`(line 43) __struct_automatic_memory_management`

## How does it work?

**__Struct** takes advantage of the fact that deactivated objects do not
run any processing events, yet their variables remain intact and
available to be read or modified.  This, in a sense, makes them
"lightweight objects".

When the first **__Struct** object is created it uses a singleton pattern
to mark itself as the "master" **__Struct** object.  When you run the
new_struct() script in your code it does the following:

	1. Creates a new __Struct object that marks itself as master=false
	2. Puts the new __Struct instance on a layer that the master has
		created, that is at depth 15999, and is visible=false.
	3. Sets its own __struct_owner variable to the instance that has
		created it.
	4. Fills in the variables you provided.
	5. Adds itself to a list of all __Struct children on the master.
	6. Deactivates itself.
	7. Returns the instance ID of the new __Struct to the script caller.

The master **__Struct** has a few variables that you can modify:

**__Struct** object -> *Create Event*

```Game Maker Language
    (line 43) __struct_automatic_memory_management = true;
    (line 47) __struct_cleanup_interval = 300;
    (line 55) __struct_cleanup_random_range = 10;
    (line 61) __struct_debug_mode = true;
```
When *__struct_automatic_memory_management* is true, the master **__Struct**
object will run its Alarm 0 Event every *__struct_cleanup_interval*
seconds (give or take *__struct_cleanup_random_range* seconds).

The memory management process in the *Alarm 0 Event* will run through
an array of all non-master **__Struct** instances, and if their
*__struct_owner* no longer exists, they are then destroyed.

When you go to change rooms you will need to use the provided
_room_goto* scripts.  These scripts run *instance_activate_layer()*
on the custom layer that all of the structs are on.  The activation
**MUST** occur prior to the room change as activation does not complete
until the end of the step.  If you were to change rooms and attempt
to activate all of the **__Struct** instances in the *Room End Event* you
will find that they do not finish activating before the room switches.

In *GameMaker Studio 2*, deactivated objects are **ALWAYS** deleted at room
change.  This is why we run an activation just prior to moving rooms.
In the *Room Start Event*, each of the **__Struct** instances will move
themselves back to their hidden layer, and will deactivate themselves.

## What are the limitations?

Since **__Struct** is technically just using regular *GameMaker* Objects to
for the structs, there are built-in variables that you cannot assign to.

In the current version of this script (1.0) I am not performing checks
to see if you are attempting to assign to built-in variables.

As each struct is a *GameMaker* Object, you could end up with **SIGNIFICANTLY**
more objects than you expected.  **BUT** these objects are deactivated, so
they will use almost no CPU time whatsoever as no Events are processed
after their *Create Event*.  In my testing, each object uses between 1KB and
3KB of memory.  Therefore 1000 structs would use roughly 2MB of RAM.
