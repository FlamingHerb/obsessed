class_name Stalking
extends StateBase

## How long it takes for her ass to attack someone.
var waiting_period: float = 0

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data: StateData = null) -> void:
	# Change action timer to appropriate amount.
	parent.action_timer.stop()
	#parent.action_timer.wait_time = parent.idle_time
	if waiting_period <= 0:
		waiting_period = parent.aggressive_time
	
	parent.action_timer.wait_time = 1.0
	parent.action_timer.start()
	
## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	# Reduce waiting time. This carries over and only regenerates after sometime.
	waiting_period -= 1.0
	print("STALKING: ", waiting_period)
	if waiting_period <= 0:
		transition_to.emit("Aggressive")
	
