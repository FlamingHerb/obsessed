@icon("res://nodes/jolli_location.svg")

#==============================================================================
# ** GameArea
#------------------------------------------------------------------------------
# This class handles the game area that the player is currently in. It will also
# reference the Obsesssed's avatar in gameplay.
#==============================================================================

class_name GameArea
extends Node2D

## The ObsessedAI's avatar in the room.
@export var obsessed_avatar: ObsessedAvatar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
