@icon("res://nodes/command_bgs.svg")

class_name StopBreathingBGSCommand
extends Commands

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	AudioManager.breathing_bgs_stop()
	return true
