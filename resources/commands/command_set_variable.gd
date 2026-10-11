@icon("res://nodes/command_set_variable.svg")

class_name SetVariableCommand
extends Commands

enum OPERATION {
	ADD,
	SUBTRACT,
	SET
}

## Switch to change status.
@export var variable: DataManager.VAR_NAME
## Value that we want to set.
@export var value: Variant
## Operation done to the value.
@export var operation: OPERATION = OPERATION.SET

@warning_ignore("unused_parameter")
func execute(node: MapEventBase) -> bool:
	var data = DataManager.get_variable(variable)
	
	match OPERATION:
		OPERATION.ADD:
			data += value
		OPERATION.SUBTRACT:
			data -= value
	
	# NO OPERATION SET. BECAUSE WE ARE OPTIMIZING IDIOTS
	DataManager.set_variable(variable, data)
	
	return true
