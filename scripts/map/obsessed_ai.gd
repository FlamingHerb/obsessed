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

## Where the obsessed starts in (the bedroom)
@export var obsessed_starting_point: MapNode
## Usual patrol route, will be ignored during some states.
@export var patrol_route: Array[MapNode]
## Game map to reference.
@export var game_map: GameMap
## Debug for Pathfinding
@export var starting_node_debug: MapNode
## Debug for Pathfinding
@export var target_node_debug: MapNode

## The initial state of the state machine. If not set, the first child node is used.
@export var initial_state: StateBase = null

## The current state of the state machine.
@onready var state: StateBase = (func get_initial_state() -> StateBase:
	return initial_state if initial_state != null else get_child(0)
).call()

## Current location of the obsession
var current_location: MapNode
## Location that the Obsessed AI last visited.
var last_visited_location: MapNode


func _ready() -> void:
	_obsession_moving(obsessed_starting_point)
	for state_node: StateBase in find_children("*", "StateBase"):
		pass

func _obsession_moving(target_area: MapNode) -> void:
	# Tell the other parts that the obsessed is exiting the area.
	if current_location:
		obsessed_exited.emit(current_location)
	
	current_location = target_area
	obsessed_entered.emit(target_area)

# I can't believe I'm using BFS now.
func _pathfind(start: MapNode, target: MapNode) -> Array[MapNode]:
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
func _transition_to_next_state(target_state: StateBase, data: Dictionary = {}) -> void:
	if not target_state:
		printerr(owner.name + ": Trying to transition to state " + target_state.name + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = target_state
	state.enter(target_state)
	state_changed.emit()
#endregion

func _on_action_timer_timeout() -> void:
	pass # Replace with function body.
