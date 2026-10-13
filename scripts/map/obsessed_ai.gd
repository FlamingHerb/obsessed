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
## How long the Obsessed idles.
@export var idle_time: float
## How long the Obsessed becomes aggressive.
@export var aggressive_time: float
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

## Current location of the obsession
var current_location: MapNode
## Location that the Obsessed AI last visited.
var last_visited_location: MapNode
## It MUST have an idea the current GameArea loaded.
## This is only a variable that the MAINGAMEFRAME will touch.
var player_game_area: GameArea

func _ready() -> void:
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
	print("DEBUG: Action timer paused by ", action_timer.time_left)
	action_timer.paused = true
	
## Happens when a map is not changing.
func _map_changing_end() -> void:
	print("DEBUG: Action timer resumed with ", action_timer.time_left)
	action_timer.paused = false

func obsession_moving(target_area: MapNode) -> void:
	# Tell the other parts that the obsessed is exiting the area.
	if current_location:
		obsessed_exited.emit(current_location)
	
	current_location = target_area
	print("OBSESSION DEBUG: Moving to ", current_location)
	obsessed_entered.emit(target_area)

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
func _transition_to_next_state(target_state_path: String) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path)
	
	print(state.name, " is now active!")
	state_changed.emit()

# Tell current state that the timer has timed out.
func _on_action_timer_timeout() -> void:
	# Finally, call the current state.
	state.action_timer_timeout(action_timer)
#endregion
