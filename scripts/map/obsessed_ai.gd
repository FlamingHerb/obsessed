@icon("res://nodes/command_pov_switch.svg")
#==============================================================================
# ** Obsessed AI
#------------------------------------------------------------------------------
# The AI for the Obsessed. Self-explanatory.
# References: https://github.com/gdquest-demos/godot-design-patterns/blob/main/godot/finite_state_machine/node_version/state_machine.gd
#==============================================================================

class_name ObsessedAI
extends Node

signal obsessed_entered(target_area: MapNode)
signal obsessed_exited(current_area: MapNode)
signal state_changed()
signal initiate_game_over()

@export_category("Required")
## Where the obsessed starts in (the bedroom)
@export var obsessed_starting_point: MapNode
## Usual patrol route, will be ignored during some states.
@export var patrol_route: Array[MapNode]
## These rooms are considered safe for sleeping... until they venture down.
@export var sleep_guard: Array[MapNode]
## Game map to reference.
@export var game_map: GameMap
## The initial state of the state machine. If not set, the first child node is used.
@export var initial_state: StateBase = null
@export_category("Obsessed Stats")
## How long the Obsessed will sleep until she wakes up.
@export var sleeping_period: float 
## How long the Obsessed patrols (moves between maps).
@export var patrol_time: float
## How long the Obsessed immediately hones in on player after something occurs.
@export var patrol_reaction: float
## How long the Obsessed idles.
@export var idle_time: float
## How long the Obsessed becomes aggressive after stalking.
@export var aggressive_time: float
## How long the Obsessed attacks the player after loading into the map.
@export var aggression_reaction_time: float
@export_category("Debugging")
## Debug for Pathfinding
@export var starting_node_debug: MapNode
## Debug for Pathfinding
@export var target_node_debug: MapNode

## Action timer.
@onready var action_timer: Timer = $ActionTimer
## The current state of the state machine.
@onready var state: StateBase = (func get_initial_state() -> StateBase:
	return initial_state if initial_state != null else get_child(0)
).call()
## Expose Stalking state
@onready var stalking_state: Stalking = $Stalking
## Sprite2D that we will manipulate
@onready var obsessed_sprite: AnimatedSprite2D = $ObsessedSprite
## Animation player only for us.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const obsessed_enter_sfx := [
	"res://assets/audio/se/obsessed_in_room_1.ogg",
	"res://assets/audio/se/obsessed_in_room_2.ogg"
]

const obsessed_patrol_sfx := [
	"res://assets/audio/se/obsessed_patrol_1.ogg",
	"res://assets/audio/se/obsessed_patrol_2.ogg"
]

## Current location of the obsession
var current_location: MapNode
## Location that the Obsessed AI last visited.
var last_visited_location: MapNode
## Previous state that the AI was in.
var previous_state: StateBase
## It MUST have an idea the current GameArea loaded.
## This is only a variable that the MAINGAMEFRAME will touch.
var player_game_area: GameArea

func _ready() -> void:
	stalking_state.waiting_period = aggressive_time
	# Connect signals.
	Events.state_change_force.connect(_transition_to_next_state)
	
	# It should know if a transition occurs.
	Events.change_map.connect(_map_changing)
	# And it should know when it ends.
	Events.area_change_completed.connect(_map_changing_end)
	
	obsession_moving(obsessed_starting_point)
	for state_node: StateBase in find_children("*", "StateBase"):
		state_node.transition_to.connect(_transition_to_next_state)
		
	await owner.ready
	state.enter("")
	
	action_timer.start()

## Happens when a map is changing.
func _map_changing(_path: String) -> void:
	# Pauses timer for a while.
	#print("DEBUG: Action timer paused by ", action_timer.time_left)
	action_timer.paused = true
	
## Happens when a map is finishing changing.
func _map_changing_end() -> void:
	#print("DEBUG: Action timer resumed with ", action_timer.time_left)
	action_timer.paused = false

func obsession_moving(target_area: MapNode) -> void:
	# Tell the other parts that the obsessed is exiting the area.
	if current_location:
		obsessed_exited.emit(current_location)
		
	current_location = target_area
	#print("OBSESSION DEBUG: Moving to ", current_location)
	
	# Check obsessed's possible state.
	check_for_next_state()
	
	# Check if obsessed is going to that location.
	check_to_show_obsessed_avatar()
	
	# Check to see if sound will be emitted when moving.
	check_if_sound_emitted()
	
	obsessed_entered.emit(target_area)

## Checks where it is good to show the Obsessed's avatar
func check_to_show_obsessed_avatar() -> void:	
	if not _null_check(): return
	
	# NOTE: The only thing that shows the sprite!
	# Check if the player is in the area.
	if _check_if_player_obsessed_in_same_room():
		#print("OBSESSION DEBUG: She's here.")
		
		if stalking_state.waiting_period > 0:
			player_game_area.obsessed_avatar.change_sprite(ObsessedAvatar.SPRITE_NUM.STALKING)
		else:
			player_game_area.obsessed_avatar.change_sprite(ObsessedAvatar.SPRITE_NUM.AGGRESSIVE)
		
		# Only do this if the obsessed avatar is not visible yet.
		if not player_game_area.obsessed_avatar.visible:
			player_game_area.obsessed_avatar.show()
			player_game_area.obsessed_avatar.modulate = Color(1, 1, 1, 0)
		
			var tween = create_tween().set_parallel(true)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(player_game_area.obsessed_avatar, "modulate", Color(1, 1, 1, 1), 0.33)
	else: 
		#print("OBSESSION DEBUG: She's not here.")
		
		# Hide her again if she's there.
		if player_game_area.obsessed_avatar.visible:
			var new_tween = create_tween().set_parallel(true)
			new_tween.set_ease(Tween.EASE_IN_OUT)
			new_tween.tween_property(player_game_area.obsessed_avatar, "modulate", Color(1, 1, 1, 0), 0.33)
			#await new_tween.finished
		
		player_game_area.obsessed_avatar.hide()

## Separate instead for checking.
func check_for_next_state() -> void:
	if not _null_check(): return
	
	if _check_if_player_obsessed_in_same_room():
		# If she's there, turn her into stalking.
		if stalking_state.waiting_period > 0:
			#player_game_area.obsessed_avatar.change_sprite(ObsessedAvatar.SPRITE_NUM.STALKING)
			_transition_to_next_state("Stalking")
		else:
			#player_game_area.obsessed_avatar.change_sprite(ObsessedAvatar.SPRITE_NUM.AGGRESSIVE)
			_transition_to_next_state("Aggressive")
	else:
		# If the Obsessed managed to find the player...
		if (state is Stalking or state is Aggressive) and state is not FightRoute:
			# Target player's last known location.
			var stalk_patrol: PatrolData = PatrolData.new()
			stalk_patrol.target_area = player_game_area.name
			_transition_to_next_state("Patrolling", stalk_patrol)
			
			# NOTE: Originally, after finding the player, it would patrol again.
			#if previous_state is Patrolling:
				#var continue_patrol: PatrolData = PatrolData.new()
				#continue_patrol.continue_patrol = true
				#_transition_to_next_state("Patrolling", continue_patrol)
			#else:
				#_transition_to_next_state("Idle")

## Checks if a sound should be emitted if the Obsessed is anywhere.
func check_if_sound_emitted() -> void:
	if not _null_check(): return
	
	# If the obsessed is in the room, announce itself depending on its state.
	if _check_if_player_obsessed_in_same_room():
		if state is Stalking:
			AudioManager.sfx_play(obsessed_enter_sfx.pick_random(), 0.05)
		if state is Aggressive:
			pass
		
	# If not, check if it is hovering over a neighbouring area.
	else:
		# Get the player's map node.
		var player_map_node: MapNode = game_map.return_equivalent_map_node(player_game_area.name)
		# Get distance from player. Also turn it to float for division.
		var obsessed_distance := float(len(pathfind(player_map_node, current_location)))
		print("Obsessed Distance from player: ", obsessed_distance)
		
		# If idle, play the sounds specific to that room.
		if state is Idle:
			# If it is empty, don't bother.
			if current_location.idle_audio_pack.is_empty(): return
			
		# If patrolling, play the sounds specific to patrolling.
		if state is Patrolling:
			print("Sound: ", linear_to_db(1.0 / (obsessed_distance * obsessed_distance)))
			AudioManager.sfx_play(obsessed_patrol_sfx.pick_random(), 1.0 / (obsessed_distance * obsessed_distance))
		

#region Helper functions
# Helper function
func _null_check() -> bool:
	# Null check
	if not player_game_area: return false
	# If state is Sleeping, ignore.
	if state is Sleeping: return false
	
	# Truthy moment
	return true

func _check_if_player_obsessed_in_same_room() -> bool:
	return player_game_area.name == current_location.map_name
	
## The impassable start. Forces timer action shutdown, and then kills the player.
func start_game_over() -> void:
	initiate_game_over.emit() # Emit first.
	
	action_timer.stop() # Shuts down action timer.
	
	# NOTE: Might be faulty.
	#get_viewport().set_process_input(false) # Disable player input.
	
	# Either quick death or not.
	if randf() < 0.5:
		animation_player.play("death")
	else:
		animation_player.play("quick_death")
		
	await animation_player.animation_finished # Wait.
	await Events.wait(1)
	
	get_tree().change_scene_to_packed(preload("res://scenes/game_over.tscn"))
		

#endregion Helper functions

# I can't believe I'm using BFS now.
func pathfind(start: MapNode, target: MapNode) -> Array[MapNode]:
	var parent := {start: null}
	var queue: Array[MapNode] = [start]
	
	while not queue.is_empty():
		var current_node: MapNode = queue.pop_front()
		
		if current_node == target:
			var path: Array[MapNode] = []
			while current_node != null:
				path.append(current_node)
				current_node = parent[current_node]
			path.reverse()
			print(path)
			return path
		
		for child in current_node.map_neighbours:
			if not parent.has(child): # Check if there's already instances.
				parent[child] = current_node
				queue.append(child)
	
	return []

#region State Machine Handlers
func _transition_to_next_state(target_state_path: String, data: StateData = null) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	if target_state_path == state.name:
		print("Uh, what are you doing? You're just entering another state.")
		return

	var previous_state_path := state.name
	previous_state = state
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
	
	print(state.name, " is now active!")
	state_changed.emit()

# Tell current state that the timer has timed out.
func _on_action_timer_timeout() -> void:
	# Finally, call the current state.
	print("State: ", state.name, " | Time: ", action_timer.wait_time)
	state.action_timer_timeout(action_timer)
#endregion
