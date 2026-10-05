#==============================================================================
# ** Map Node
#------------------------------------------------------------------------------
# Display node for the map. Will contain neighbours and such. The graphical side
# is only for when a display is needed for debug.
#==============================================================================

class_name MapNode
extends Control

signal obsessed_entered
signal obsessed_exited
signal player_entered
signal player_exited

## Name to display in debug.
@export var map_name: String
## Scene to use when referring to this map node.
@export var map_scene: PackedScene
## Used by the Obsessed AI's traversal.
@export var map_neighbours: Array[MapNode]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = map_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
