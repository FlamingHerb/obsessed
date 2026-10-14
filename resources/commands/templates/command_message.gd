@icon("res://nodes/command_message.svg")

class_name GabWindowTextCommand
extends Commands

## Can be BB-Code to use.
@export var window_text: String
## How long the gab window will be shown
@export var seconds: float = 5

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	Events.show_gab_window_text(window_text, seconds)
	return true
