@icon("res://nodes/event_page.svg")
#==============================================================================
class_name EventPage
extends Resource
#------------------------------------------------------------------------------
# This resouce handles basically how an event page can occur in the game. This
# is inspired (or based) from the RPG Maker engines. An event can have multiple
# event pages alone for that fact.
#
# Event pages will NOT run the commands, but rather the events themselves!
#
#==============================================================================

enum TRIGGER_TYPE {
	## If CONTACT, player input is required.
	CONTACT,
	## If AUTORUN, will execute and then end.
	AUTORUN,
	## If PARALLEL, will execute and end only when event is forced out.
	PARALLEL
}

@export_category("Triggers")
## Switches required to activate this event page.
@export var switch_triggers: Array[DataManager.SWCH_NAME]
## Variables required to activate this event page.
@export var variable_triggers: Array[VariableCondition]
## Self-switches required to activate this event page.
@export var self_switch_triggers: Array[String]


@export_category("Properties")
## Type of Trigger to show.
@export var trigger: TRIGGER_TYPE
## Offset to issue for this specific event page.
@export var offset_issued: Vector2
## Turn this transparent after the triggers.
@export var transparent: bool
## Graphic node to refer to. Must be inside MapEventBase.
## Will only show when specific conditions are set.
@export var graphic: String

@export_category("Commands")
## Commands to run for this event page.
@export var commands: Array[Commands]
