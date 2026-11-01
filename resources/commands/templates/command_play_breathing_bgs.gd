@icon("res://nodes/command_bgs.svg")

class_name PlayBreathingBGSCommand
extends Commands

## Audio file to play
@export_file("*.mp3","*.wav","*.ogg") var audio_file
## Volume to use
@export var volume: float = 1.0

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	AudioManager.breathing_bgs_play(audio_file)
	AudioManager.breathing_bgs_volume(volume)
	return true
