@icon("res://nodes/command_sfx.svg")

class_name PlaySFXCommand
extends Commands

## Audio file to play
@export_file("*.mp3","*.wav","*.ogg") var audio_file
## Volume from 0.0 to 1.0 in float linear terms
@export var volume: float = 1.0

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	AudioManager.sfx_play(audio_file, volume)
	return true
