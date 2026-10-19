class_name Idle
extends StateBase

## The probability for the obsessed to idle.
@export var idling_probability: float = 0.4
## How long until too many idles is considered a problem?
@export var min_idle_steps := 2
## How fast the probability ramps up.
@export var ramp_steps := 20

var idle_steps := 0

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data: StateData = null) -> void:
	print("Let's check first: ", previous_state_path)
	# If the player was found, let's try stalking.
	if previous_state_path == "Stalking":
		print("")
		
	# Change action timer to appropriate amount.
	state_timer_reset()

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	idle_steps = 0

func exit_chance(s: int) -> float:
	var the_value := clampf(idling_probability + float(s - min_idle_steps) / ramp_steps, 0.0, 1.0)
	print(the_value)
	return the_value

## Reset the timer given that a move has been force.
func state_timer_reset() -> void:
	# Change action timer to appropriate amount.
	parent.action_timer.stop()
	#parent.action_timer.wait_time = parent.idle_time
	parent.action_timer.start(parent.idle_time)

## Called when the action timer from the Obsessed AI parent is calling.
func action_timer_timeout(action_timer: Timer) -> void: 
	# if lower than idling probability, start patrolling.
	var randomizer := randf()
	#print("Idling chance: ", randomizer)
	if randomizer < exit_chance(idle_steps):
		transition_to.emit("Patrolling")
	else:
		idle_steps += 1
		#print("Currently idling")
