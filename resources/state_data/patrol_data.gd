@icon("res://nodes/command_set_variable.svg")

class_name PatrolData
extends StateData

## Target area (must make sure that it is at least something that is from the
## map).
@export var target_area: String
## Check if a patrol was interrupted.
@export var continue_patrol: bool = false
