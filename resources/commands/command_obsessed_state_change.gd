@icon("res://nodes/command_pov_switch.svg")

class_name ObsessedStateChangeCommand
extends Commands

## Target area (must make sure that it is at least something that is from the
## map).
@export var target_state: String
## Data to send to the state
@export var data: StateData

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	Events.force_state_change(target_state, data)
	return true
