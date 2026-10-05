@icon("res://nodes/command_pov_switch.svg")
#==============================================================================
# ** Obsessed AI
#------------------------------------------------------------------------------
# The AI for the Obsessed. Self-explanatory.
#==============================================================================

class_name ObsessedAI
extends Node

signal obsessed_entered(target_area: MapNode)
signal obsessed_exited(current_area: MapNode)

## Where the obsessed starts in (the bedroom)
@export var obsessed_starting_point: MapNode
## Usual patrol route, will be ignored during some states.
@export var patrol_route: Array[MapNode]

## Current location of the obsession
var current_location: MapNode

func _ready() -> void:
	_obsession_moving(obsessed_starting_point)

func _obsession_moving(target_area: MapNode) -> void:
	# Tell the other parts that the obsessed is exiting the area.
	if current_location:
		obsessed_exited.emit(current_location)
	
	current_location = target_area
	obsessed_entered.emit(target_area)
