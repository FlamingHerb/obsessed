@icon("res://nodes/command_scene_change.svg")

class_name SceneChangeCommand
extends Commands

## Destination of the scene change.
@export_file_path var destination: String

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	Events.change_area(destination)
	return true
