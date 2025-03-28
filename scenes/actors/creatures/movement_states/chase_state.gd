extends State

@export var speed := 300.0

@onready var _returning_state: State = %ReturningState

var _is_active := false

var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	user.speed = speed
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d

	_returning_state.last_position = user.global_position
	
	if info.has("located"):
		_navigation_agent_3d.target_position = info["located"]

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		user.end_buffered = true

	if info.has("located"):
		_navigation_agent_3d.target_position = info["located"]
		return

	if info.has("arrived"):
		state_machine.change_state("WanderingState", {"next_state": "ReturningState"})

func end() -> void:
	_is_active = false
