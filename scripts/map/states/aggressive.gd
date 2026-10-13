class_name Aggressive
extends StateBase

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data: StateData = null) -> void:
	# Change action timer to appropriate amount.
	parent.action_timer.stop()
	#parent.action_timer.wait_time = parent.idle_time
	
	## See if it's plausible since you're in the room.
	parent.check_to_show_obsessed_avatar()
	
	parent.action_timer.start(parent.aggression_reaction_time)

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	print("AGGRESSIVE: CONGRATS! You should be dead by now.")
	
