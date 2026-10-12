#==============================================================================
# ** State Base
#------------------------------------------------------------------------------
# References: https://github.com/gdquest-demos/godot-design-patterns/blob/main/godot/finite_state_machine/node_version/state_machine.gd
#==============================================================================
class_name StateBase
extends Node

signal transition_to(next_state_path: String)

## The state's parent.
@onready var parent: ObsessedAI

func _ready() -> void:
	parent = get_parent()

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String) -> void:
	print("From: ", previous_state_path)

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	print(name, ": Action Timer Expiring")
