@icon("res://nodes/command_pov_switch.svg")
#==============================================================================
# ** ObsessedAvatar < MapEvent Base
#------------------------------------------------------------------------------
# This class handles the avatar of the ObsessedAI. It is only graphical in nature
# and does not contain the full logic of the AI.
#==============================================================================

class_name ObsessedAvatar
extends MapEventBase

var stalking_sprite: Texture2D = preload("res://assets/graphics/obsessed/obsessed-stalk-no-eyes.png") 
var aggressive_sprite: Texture2D = preload("res://assets/graphics/obsessed/obsessed-stalk.png") 

@export var sprite: Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# Defaults to stalking
	sprite.texture = stalking_sprite
	
	hide()	

## Override for maximum scares.
func _on_mouse_entered() -> void:
	pass

## Override for maximum scares.
func _on_mouse_exited() -> void:
	pass
