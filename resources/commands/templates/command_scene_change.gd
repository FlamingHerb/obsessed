@icon("res://nodes/command_scene_change.svg")

class_name SceneChangeCommand
extends Commands

## Destination of the scene change.
@export_file_path var destination: String
## If it exists, apply sound when initiating transition:
@export_file_path(".ogg", ".mp3", ".wav") var open_sfx: String = "res://assets/audio/se/quiet_door.ogg"
## If it exists, apply sound when exiting transition:
@export_file_path(".ogg", ".mp3", ".wav") var close_sfx: String = "res://assets/audio/se/close_queit.ogg"

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	if open_sfx: AudioManager.sfx_play(open_sfx)
	Events.change_area(destination)
	await Events.area_change_completed
	if close_sfx: AudioManager.sfx_play(close_sfx)
	
	return true
