@icon("res://nodes/command_sfx.svg")

class_name StopSFXAllCommand
extends Commands

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> void:
	AudioManager.sfx_stop_all()
	super(node)
