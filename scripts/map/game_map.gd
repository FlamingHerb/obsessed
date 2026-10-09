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
	hide()
	
	obsession_ai.obsessed_entered.connect(_obsession_entering_area)
	obsession_ai.obsessed_exited.connect(_obsession_exiting_area)
	
	Events.change_map.connect(_player_moving)
	
	_generate_line_route()

func _player_moving(map_node_path: String) -> void:
	# I am so just bored lemaw.
	for child: MapNode in find_children("*", "MapNode"):
		if child.map_scene.resource_path == map_node_path: child.player_icon.show()
		else: child.player_icon.hide()

func _obsession_entering_area(target_area: MapNode) -> void:
	target_area.obsessed_icon.show()

func _obsession_exiting_area(target_area: MapNode) -> void:
	target_area.obsessed_icon.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if Input.is_action_just_pressed("debug_map"):
		if self.visible: hide()
		else: show()

func _generate_line_route() -> void:
	for child: MapNode in find_children("*", "MapNode"):
		for node_neighbour: MapNode in child.map_neighbours:
			var line_2d = Line2D.new()
			line_2d.default_color = Color(Color.RED)
			line_2d.add_point(child.position + Vector2(20, 20))
			line_2d.add_point(node_neighbour.position + Vector2(20, 20))
			add_child(line_2d)
			move_child(line_2d, 0)
