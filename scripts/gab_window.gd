class_name GabWindow
extends PanelContainer

@onready var rich_text: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(0.0, 0.0, 0.0, 0)
	rich_text.text = ""
	Events.gab_window_text.connect(_gab_window_text_show)

func _gab_window_text_show(text_to_show: String, seconds: float) -> void:
	# Force stop animation player.
	if animation_player.is_playing(): animation_player.stop()
	
	rich_text.text = text_to_show
	animation_player.play("show")
	#await animation_player.animation_finished
	timer.start(seconds)

func hide_text(forced: bool = false) -> void:
	if not forced: 
		animation_player.play_backwards("show")
		#await animation_player.animation_finished
	else:
		if animation_player.is_playing(): animation_player.stop()
		modulate = Color(0.0, 0.0, 0.0, 0)
		
	rich_text.text = ""

# After a while, hide the gab window.
func _on_timer_timeout() -> void:
	hide_text()
