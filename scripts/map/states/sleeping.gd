class_name Sleeping
extends StateBase

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	var sleep_guard_name := parent.sleep_guard.map(func(element: MapNode): return String(element.name))
	
	if parent.player_game_area.name in sleep_guard_name: 
		print("DEBUG: We're good")
	else:
		print("Decreasing sleep: ", parent.sleeping_period)
		parent.sleeping_period -= 1
	
	# If no longer threshold, wake her up.
	if parent.sleeping_period < 0:
		transition_to.emit("Idle")
