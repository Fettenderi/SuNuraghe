class_name StateMachine
extends Node

## A node for managing [State] nodes.
##
## The [StateMachine] class manages its [State] children, allowing transitions between them using [method change_state].
## Information can be exchanged between the [StateMachine] and its [member user] using [param info] parameter during transition and [method update].

## Reference to the node that uses the [StateMachine]. This reference is passed to all its [State] children.
@export var user : Node

## Starting [State] of the [StateMachine]. Initialized using [method start].
@export var starting_state : State

## Additional information passed to [member starting_state] on initialization.
@export var starting_info : Dictionary

## Automatically executes [method start] after the node has entered the scene.
@export var automatic := false

@export var verbose := false

@onready var _states : Array[State]

## Reference to the currently active [State] of the [StateMachine]
var current_state : State

var _is_active := false
var _states_names : Array[String] = []

func _ready():
	current_state = starting_state
	if current_state is State:
		current_state.state_machine = self
		current_state.user = user
	
	for _state in get_children():
		if _state is State:
			_states.append(_state)
			_states_names.append(_state.name)
	
	if automatic:
		start()

## Starts the [StateMachine] using the [member starting_state] [State].
func start():
	if verbose:
		print("State Machine Started")
		print(str(current_state) + " Started")
	current_state.start(starting_info)
	_is_active = true

## Updates [member current_state] [method update] when the [StateMachine] is active.[br][br]
## You can provide additional informations to [member current_state] using [param info]
func update(info : Dictionary = {}):
	if _is_active:
		if not current_state.state_machine:
			current_state.state_machine = self
		if verbose:
			print(str(current_state) + " Updated")
		current_state.update(info)

## Transitions [member current_state] into [param state_name].
## It firstly executes [method State.end] on [member current_state] and then [method State.start] on [param state_name] [State].[br][br]
## You can provide additional informations to the new [State] using [param info]
func change_state(state_name : String, info : Dictionary = {}):
	if state_name == current_state.name or not _is_active: 
		if verbose:
			print(str(current_state) + " Updated")
		current_state.update(info)
		return
	
	if verbose:
		print(str(current_state) + " Ended")
	current_state.end()
	current_state = _states[_states_names.find(state_name)]
	if current_state is State:
		current_state.state_machine = self
		current_state.user = user
		if verbose:
			print(str(current_state) + " Started")
		current_state.start(info)

## Stops the [StateMachine].
func stop():
	if verbose:
		print("State Machine stopped")
	_is_active = false
