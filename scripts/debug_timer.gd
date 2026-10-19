extends Label

@export var obsessed_ai: ObsessedAI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide only on prod.
	if not OS.is_debug_build(): hide()
	else: show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = var_to_str(obsessed_ai.action_timer.time_left)
