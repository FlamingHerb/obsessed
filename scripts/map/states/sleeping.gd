class_name Sleeping
extends StateBase

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	var sleep_guard_name := parent.sleep_guard.map(func(element: MapNode): return String(element.name))
	print(sleep_guard_name)
	print(parent.player_game_area)
	if parent.player_game_area.name in sleep_guard_name: 
		print("We're good.")
	else:
		print("We're not good.")
	#print(name, ": Action Timer Expiring")
