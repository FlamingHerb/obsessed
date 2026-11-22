@icon("res://nodes/command_bgm.svg")

class_name StopBGMCommand
extends Commands

## Seconds to fade out from.
@export var fade: float = 0.0

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> void:
	AudioManager.bgm_stop(fade)
	super(node)
