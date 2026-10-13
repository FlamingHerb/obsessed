class_name Patrolling
extends StateBase

var patrol_line: Array[MapNode]

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String) -> void:
	# Change action timer to appropriate amount.
	parent.action_timer.stop()
	
	# Plot out route. Cannot be its current position.
	var possible_route: Array[MapNode] = parent.patrol_route.duplicate_deep()
	# Remove its current location from its possible route.
	possible_route.erase(parent.current_location)
	print("Possible Routes: ", len(possible_route), " - ", possible_route)
	# Then, from its current route, pathfind to its new route randomly chosen.
	patrol_line = parent.pathfind(parent.current_location, possible_route.pick_random())
	# And for some reason remove current route.
	patrol_line.erase(parent.current_location)
	
	print("Patrol: ", patrol_line)
	
	# Resume patrol time.
	parent.action_timer.start(parent.patrol_time)

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	if patrol_line.is_empty():
		transition_to.emit("Idle")
	else:
		parent.obsession_moving(patrol_line.pop_front())
