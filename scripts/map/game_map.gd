@icon("res://nodes/map.svg")
#==============================================================================
# ** Game Map
#------------------------------------------------------------------------------
# Parent node for the Map Nodes
#==============================================================================

class_name GameMap
extends Control

## The Obsession AI that it will refer to.
@export var obsession_ai: ObsessedAI

func _ready() -> void:
	obsession_ai.obsessed_entered.connect(_obsession_entering_area)
	obsession_ai.obsessed_exited.connect(_obsession_exiting_area)
	
	Events.change_map.connect(_player_moving)

func _player_moving(map_node: MapNode) -> void:
	# I am so just bored lemaw.
	for child: MapNode in get_children():
		if child == map_node: child.player_icon.show()
		else: child.player_icon.hide()

func _obsession_entering_area(target_area: MapNode) -> void:
	target_area.obsessed_icon.show()

func _obsession_exiting_area(target_area: MapNode) -> void:
	target_area.obsessed_icon.hide()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_map"):
		if self.visible: hide()
		else: show()
