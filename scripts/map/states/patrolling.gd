class_name Patrolling
extends StateBase

var patrol_line: Array[MapNode]

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data: StateData = null) -> void:
	# Change action timer to appropriate amount.
	parent.action_timer.stop()
	
	# Check if we have to force due to sound that will alert the obsessed.
	if data and data is PatrolData:
		#print("PATROL DEBUG: Getting them data.")
		# Type checking in a new world order type beat
		var new_data: PatrolData = data
		
		# Check if it is going to continue a patrol or not.
		if new_data.continue_patrol:
			print("PATROL DEBUG: Continuing patrol")
		if new_data.target_area:
			print("PATROL DEBUG: SNIFFING NEW TARGGET")
			var target: MapNode = parent.game_map.find_child(new_data.target_area)
			patrol_line = parent.pathfind(parent.current_location, target)
		
		parent.action_timer.wait_time = parent.patrol_reaction
		parent.action_timer.start(parent.patrol_reaction)
	else:
		_natural_route_generation()
	
		# Resume patrol time.
		parent.action_timer.wait_time = parent.patrol_time
		parent.action_timer.start(parent.patrol_time)

func _natural_route_generation() -> void:
	# Plot out route. Cannot be its current position.
	var possible_route: Array[MapNode] = parent.patrol_route.duplicate_deep()
	# Remove its current location from its possible route.
	possible_route.erase(parent.current_location)
	#print("Possible Routes: ", len(possible_route), " - ", possible_route)
	
	var route_generator = possible_route.map(_map_route_generator)
	#var biggest = route_generator.reduce(func(a, b): return a if a.size() >= b.size() else b)
	#print("Biggest: ", find_largest_arrays(route_generator).pick_random())
	
	# Then, from its current route, pathfind to its new route randomly chosen.
	#patrol_line = parent.pathfind(parent.current_location, possible_route.pick_random())
	patrol_line = find_largest_arrays(route_generator).pick_random()
	# And for some reason remove current route.
	patrol_line.erase(parent.current_location)
	
	#print("Patrol: ", patrol_line)

## Map route generator
func _map_route_generator(target_node: MapNode) -> Array[MapNode]:
	return parent.pathfind(parent.current_location, target_node)

## Find the largest one.
## The minimum is, at most, 4.
func find_largest_arrays(grid: Array) -> Array:
	var largest: Array = []  # array of arrays
	var best_size := -1
	for row in grid:
		# DEPRECATED: Originally
		#if row.size() > best_size: 
			#best_size = row.size()
			#largest = [row]
		#elif row.size() == best_size:
			#largest.append(row)
		if row.size() > 3: 
			largest.append(row)
	#print("Largest Arrays: ", largest)
	return largest

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	if patrol_line.is_empty():
		transition_to.emit("Idle")
	else:
		# Add variance
		parent.obsession_moving(patrol_line.pop_front())
