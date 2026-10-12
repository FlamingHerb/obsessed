@icon("res://nodes/map_event.svg")
#==============================================================================
# ** MapEventBase
#------------------------------------------------------------------------------
# This class handles how events work all around gameplay. This essentially makes
# events custom and modular for easy editing, as opposed to the static design
# that it originally had.
#==============================================================================

class_name MapEventBase
extends Area2D

## The page list to run. It will run the bottom-most first, and then stop.
@export var event_page_list: Array[EventPage]

## Used to track the current command that is running.
var index: int = 0
## Event page that will be used.
var current_page: EventPage
## Semiotic lock... kinda.
var lock: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect in case other events may clash.
	Events.event_running.connect(_another_event_running)
	
	# Connect for any data changes.
	DataManager.data_changed.connect(_find_suitable_page)
	
	# Making sure every map event has at least a page, even if it is empty.
	assert(event_page_list.size() > 0, "ERROR: You forgot to add in an event page!")
	
	# In the possibility that, when you load in and there's no triggers, it will
	# activate the following.
	_find_suitable_page()

func _another_event_running(running: bool) -> void:
	pass

func _process(_delta: float) -> void:
	if current_page:
		if current_page.trigger == EventPage.TRIGGER_TYPE.AUTORUN:
			_activate_event_page(current_page)
		elif current_page.trigger == EventPage.TRIGGER_TYPE.PARALLEL:
			_activate_event_page(current_page)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				interact()
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_MASK_RIGHT:
				if not OS.is_debug_build(): return
				print("[DEBUG] Current active page: ", current_page.resource_name)
				get_viewport().set_input_as_handled()

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# When DataManager changes, find a better page host.
func _find_suitable_page() -> void:
	for i in range(event_page_list.size() - 1, -1, -1):
		var event_page: EventPage = event_page_list[i]
		if _meets_conditions(event_page):
			# Once conditions are met, also change visibility of some things.
			visible = not event_page.transparent
			position += event_page.offset_issued
			
			current_page = event_page
			break

# Check conditions through a rather fun way.
func _meets_conditions(event_page: EventPage) -> bool:
	var switches_ok = event_page.switch_triggers.all(func(s): return DataManager.get_switch(s))
	var variables_ok = event_page.variable_triggers.all(func(v: VariableCondition): return v.is_met())
	var self_switches_ok = event_page.self_switch_triggers.all(func(s): return DataManager.get_self_switch(self.get_parent().name + name + s))
	print(name, ": ", switches_ok, " ", variables_ok, " ", self_switches_ok)
	return switches_ok and variables_ok and self_switches_ok

# Runs the event itself.
func _activate_event_page(event_page: EventPage) -> void:
	# Disrupt any attempt to run the event page if another event page is
	# already running.
	if lock: return
	
	lock = true
	index = 0
	
	# REFACTOR this.
	
	while index < len(event_page.commands):
		var command = event_page.commands[index]
		if command is EndEventCommand: break
		
		# Debugging
		print("Running command #", index, ": " , command.get_script().get_global_name())
		
		@warning_ignore("redundant_await")
		await command.execute(self)
		index += 1 
	
	print("DEBUG: Event ended.")
	lock = false

# Run the interaction.
func interact() -> void:
	if current_page and current_page.trigger == EventPage.TRIGGER_TYPE.CONTACT:
		_activate_event_page(current_page)
