@icon("res://nodes/command_end_event.svg")

class_name EraseEventCommand
extends Commands

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	node.queue_free()
	return true
