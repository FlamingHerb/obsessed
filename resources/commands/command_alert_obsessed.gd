@icon("res://nodes/command_pov_switch.svg")

class_name AlertObsessedCommand
extends Commands

## Target area (must make sure that it is at least something that is from the
## map).
@export var target_area: String
## Initiates actual fight mode sequence.
@export var fight_route_initiate: bool = false

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	Events.obsessed_alert(target_area, fight_route_initiate)
	return true
