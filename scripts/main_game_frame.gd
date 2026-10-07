@icon("res://nodes/game_main.svg")

class_name MainGameFrame
extends Node

#region Initialized Variables and Exports

# INFO: Exported variables
@export var starting_scene: MapNode

# INFO: Onready variables
@onready var game_area = $GameArea


## INFO: Other variables
## Sets Adi as the default POV character.
var current_area_name: String = "GameArea"

@onready var game_map: GameMap = $GameMap
@onready var animation_player: AnimationPlayer = $AnimationPlayer


#endregion

#region Virtual functions
func _ready() -> void:
	# INFO: Tell events that you are the GameMainFrame.
	Events.game_main = self
	
	# INFO: Initialize connections to the Events scene.
	Events.change_map.connect(_goto_area)
	
	Events.current_scene_context = Events.SCENE_CONTEXT.IN_GAME

	# INFO: Initialize Events singleton for a new game.
	Events.initialize()
		
	# INFO: Start game. Kinda funny we're doing loop-de-loops here.
	Events.change_area(starting_scene)
#endregion

func _input(_event: InputEvent) -> void:
	pass

#region Area Change Functions
## First is path.
func _goto_area(map_node: MapNode) -> void:
	var path = map_node.map_scene.resource_path
	if ResourceLoader.exists(path):
		call_deferred("_deferred_change_area", path)
	
## Changes scene. Deferred JUST IN CASE.
func _deferred_change_area(path: String) -> void:
	# bc global @export var current_scene at top of file
	# unless want to rename ofc xD
	@warning_ignore("shadowed_variable")
	
	var current_scene = get_node(current_area_name)
	var new_scene = ResourceLoader.load(path)
	
	await _fade_out_from_scene(current_scene)
	
	current_scene.free()
	current_scene = new_scene.instantiate()
	
	# Add child...
	add_child(current_scene)
	
	# Before naming it...!
	current_area_name = current_scene.name
	#current_scene.name = "GameArea"
	current_scene.modulate = Color.BLACK
	
	# New scene must always be the second one.
	move_child(current_scene, 1)
	
	_fade_in_to_scene(current_scene)
	Events.area_change_completed.emit()
	
#endregion

#region Custom function

func _fade_out_from_scene(new_area: Node2D) -> void:
	# Make tween for fade out
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(new_area, "modulate", Color.BLACK, 0.5)
	await tween.finished

func _fade_in_to_scene(new_area: Node2D) -> void:
		# Then fade in again.
	var new_tween = create_tween().set_parallel(true)
	new_tween.set_ease(Tween.EASE_IN_OUT)
	new_tween.tween_property(new_area, "modulate", Color.WHITE, 0.5)
	await new_tween.finished

## INFO: Does not account for POVSwitch, Camera and MapTravel
func _any_menu_opened(node: Control) -> void:
	Events.any_menu_opened(node)
	
#endregion
