extends Node

#region Initialized Variables and Exports
# Scene context
enum SCENE_CONTEXT {
	IN_GAME,
	IN_MENU
}

signal change_map(path: String)
signal area_change_completed

# For save/load shortcuts
signal shortcut_save_pressed
signal shortcut_load_pressed

# For opening save/load menu
signal open_save_menu
signal open_load_menu

## When you want to force the state change
signal state_change_force(target_state_path: String)

## Signal for gab window text
signal gab_window_text(text: String, seconds: float)

# For menus opening/closing
#signal any_menu_opened_closed(node: Control)

# TODO: Expose this shit.
# ## Exposing game main instead because this architecture BLOWS.
# var game_main: MainGameFrame

# TODO: Expose this shit.
# ## Exposing save/load menu for shortcut access.
# var save_load_menu: SaveLoadMenu

## Tracks the currently loaded location scene path for save/load.
var game_main: MainGameFrame

## Current Scene Context.
var current_scene_context: SCENE_CONTEXT = SCENE_CONTEXT.IN_MENU:
	get:
		return current_scene_context
	set(value):
		print("Current scene context: ", SCENE_CONTEXT.keys()[value])
		current_scene_context = value

	# INFO: Set via open_camera(), any_menu_opened(), pause_menu.gd, game_main.gd, camera.gd, history_layer.gd

#endregion
func _init() -> void:
	pass

#region Virtual functions
#func _ready() -> void:
	#false

# For more global handling
func _unhandled_key_input(_event: InputEvent) -> void:
	# Handle fullscreen toggling.
	if Input.is_action_just_pressed("shortcut_fullscreen"):
		_fullscreen_shortcut_pressed()
		get_viewport().set_input_as_handled()
	
	if Input.is_action_just_pressed("show_menu") and current_scene_context != SCENE_CONTEXT.IN_MENU:
		get_viewport().set_input_as_handled()
		
## Initializes Events for a new game.
func initialize() -> void:
	current_scene_context = SCENE_CONTEXT.IN_GAME
#endregion

#region Custom Functions
## Wait, literally.
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, false, false, true).timeout

## Changes area to the PackedScene [param path].
## Pretty much a helper function for a signal to make code readable.
func change_area(path: String) -> void:
	change_map.emit(path)

## Resets everything when going back to main menu.
func reset()-> void:
	pass

## Force state change.
func force_state_change(target_state_path: String) -> void:
	state_change_force.emit(target_state_path)

## Show gab window text
func show_gab_window_text(text: String, seconds: float) -> void:
	gab_window_text.emit(text, seconds)

## Universal helper function to check if there's any changes for menus elsewhere.
func any_menu_opened(node: Control) -> void:
	if node.visible: 
		current_scene_context = SCENE_CONTEXT.IN_MENU
	else:
		current_scene_context = SCENE_CONTEXT.IN_GAME
#endregion

#region Custom Shortcut Handling
func _fullscreen_shortcut_pressed() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			GameSettings.fullscreen_change(false)
		_:
			GameSettings.fullscreen_change(true)
#endregion
