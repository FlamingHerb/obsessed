@icon("res://nodes/command_template.svg")

class_name Commands
extends Resource

signal command_done

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> void:
	command_done.emit()
