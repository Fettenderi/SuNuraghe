class_name State
extends Node

## Base class for all state nodes
##
## This is the base class for [State] node. It needs to have [StateMachine] as its parent node to properly work.

## Reference to the node using the [member state_machine].
var user : Node

## Reference to the assigned [StateMachine].
var state_machine : StateMachine

## Override this method to customize this [State] initialization process. Executed by the [member state_machine] when it activates this [State], upon [method StateMachine.start] or using [method StateMachine.change_state] referencing this [State].[br][br]
## Additional informations can be received by the [member state_machine] in the form of [param _info].
func start(_info : Dictionary = {}) -> void:
	pass

## Override this method to customize this [State]'s main update loop. Executed by [method StateMachine.update] when this state is active.[br][br]
## Additional informations can be received by the [member state_machine] in the form of [param _info].
func update(_info : Dictionary = {}) -> void:
	pass

## Override this method to customize this [State] ending procedure. Executed by the [member state_machine] when it deactivates this state, during the transition of a new [State].
func end() -> void:
	pass
