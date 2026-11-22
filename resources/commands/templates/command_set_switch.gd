@icon("res://nodes/command_set_switch.svg")

class_name SetSwitchCommand
extends Commands

## Switch to change status.
@export var switch: DataManager.SWCH_NAME
@export var value: bool = false

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> void:
	DataManager.set_switch(switch, value)
	super(node)
