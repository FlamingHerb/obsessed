class_name Idle
extends StateBase

## The probability for the obsessed to idle.
@export var idling_probability: float = 0.4

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data: StateData = null) -> void:
	# Change action timer to appropriate amount.
	parent.action_timer.stop()
	#parent.action_timer.wait_time = parent.idle_time
	parent.action_timer.start(parent.idle_time)

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	# if lower than idling probability, start patrolling.
	if randf() < idling_probability:
		transition_to.emit("Patrolling")
	else:
		print("Currently idling")
