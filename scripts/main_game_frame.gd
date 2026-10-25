@icon("res://nodes/game_main.svg")

class_name MainGameFrame
extends Node

#region Initialized Variables and Exports

# INFO: Exported variables
@export var starting_scene: MapNode
@export var obsessed_ai: ObsessedAI

# INFO: Onready variables
@onready var game_area = $GameLayer/GameArea

@onready var game_map: GameMap = $AnythingElse/GameMap
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gab_window: GabWindow = $AnythingElse/GabWindow
@onready var transition_black: ColorRect = $GameLayer/Transition

@onready var game_layer: CanvasLayer = $GameLayer

## INFO: Other variables
## Sets Adi as the default POV character.
var current_area_name: String = "GameArea"

#endregion

#region Virtual functions
func _ready() -> void:
	obsessed_ai.player_game_area = $GameLayer/GameArea
	
	# Needed to initiated an actual game over.
	obsessed_ai.initiate_game_over.connect(_initiate_game_over)
	
	# INFO: Tell events that you are the GameMainFrame.
	Events.game_main = self
	
	# INFO: Initialize connections to the Events scene.
	Events.change_map.connect(_goto_area)
	
	Events.current_scene_context = Events.SCENE_CONTEXT.IN_GAME

	# INFO: Initialize Events singleton for a new game.
	Events.initialize()
		
	# INFO: Start game. Kinda funny we're doing loop-de-loops here.
	Events.change_area(starting_scene.map_scene.resource_path)
	
	# Some weird stuff to point out.
	get_viewport().physics_object_picking_first_only = false
	get_viewport().physics_object_picking_sort = true
#endregion

func _input(_event: InputEvent) -> void:
	pass

#region Area Change Functions
## First is path.
func _goto_area(path: String) -> void:
	if ResourceLoader.exists(path):
		call_deferred("_deferred_change_area", path)
	
## Changes scene. Deferred JUST IN CASE.
func _deferred_change_area(path: String) -> void:
	# bc global @export var current_scene at top of file
	# unless want to rename ofc xD
	@warning_ignore("shadowed_variable")
	
	# Action timer should always be paused first.
	obsessed_ai.pause_timer(true)
	
	# When change scenes, make sure to reset gab window regardless.
	gab_window.hide_text(true)
	
	var current_scene = game_layer.get_node(current_area_name)
	var new_scene = ResourceLoader.load(path)
	
	#print("DEBUG: Deleting other Map Event Base")
	#for map_event_base: MapEventBase in current_scene.find_children("*", "MapEventBase"):
		#map_event_base.input_pickable = false
	for node: Node in current_scene.find_children("*"):
		node.set_process_input(false)
	
	await _fade_out_from_scene(current_scene)
	
	#print("Previous Scene: ", current_area_name)
	current_scene.free()
	current_scene = new_scene.instantiate()
	
	# Obsessed AI will now consider this as the new game area.
	obsessed_ai.player_game_area = current_scene
	
	# Add child...
	game_layer.add_child(current_scene)
	
	#print("DEBUG: Deactivating Map Event Base")
	for map_event_base: MapEventBase in current_scene.find_children("*", "MapEventBase"):
		map_event_base.input_pickable = false
	
	# Before naming it...!
	current_area_name = current_scene.name
	#current_scene.name = "GameArea"
	#current_scene.modulate = Color.BLACK
	
	# New scene must always be the second one.
	game_layer.move_child(current_scene, 1)
	
	# Tell the Obsessed AI to change its shit.
	obsessed_ai.map_changing_start()
	
	await _fade_in_to_scene(current_scene)
	
	#print("DEBUG: Activating Map Event Base")
	for map_event_base: MapEventBase in current_scene.find_children("*", "MapEventBase"):
		map_event_base.input_pickable = true
	
	# And once its changing shit is done...
	obsessed_ai.map_changing_end()
	
	Events.area_change_completed.emit()
	
#endregion

#region Custom function

func _fade_out_from_scene(new_area: Node2D) -> void:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	# Make tween for fade out
	#var tween = create_tween().set_parallel(true)
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(new_area, "modulate", Color.BLACK, 0.5)
	#await tween.finished

func _fade_in_to_scene(new_area: Node2D) -> void:
	animation_player.play_backwards("fade_to_black")
	await animation_player.animation_finished
		# Then fade in again.
	#var new_tween = create_tween().set_parallel(true)
	#new_tween.set_ease(Tween.EASE_IN_OUT)
	#new_tween.tween_property(new_area, "modulate", Color.WHITE, 0.5)
	#await new_tween.finished

## INFO: Does not account for POVSwitch, Camera and MapTravel
func _any_menu_opened(node: Control) -> void:
	Events.any_menu_opened(node)

## Info initated when the Obsessed AI can do a game over.
func _initiate_game_over() -> void:
	var current_scene = game_layer.get_node(current_area_name)
	
	# Disable process inputting.
	for node: Node in current_scene.find_children("*"):
		node.set_process_input(false)

#endregion
