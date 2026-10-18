extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.bgs_stop()
	
	get_viewport().set_process_input(false)
	animation_player.play("free")
	await animation_player.animation_finished
	get_viewport().set_process_input(true)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_process_input(false)
		animation_player.play_backwards("free")
		await animation_player.animation_finished
		
		get_tree().change_scene_to_file("res://scenes/title_scene.tscn")
	
