extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

@onready var _returning_state: State = %ReturningState

var _is_active := false

var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d

	_returning_state.last_position = user.global_position
	
	if info.has("speed"):
		max_speed = info["speed"]
	
	if info.has("located"):
		_navigation_agent_3d.target_position = info["located"]


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		var _toucher : Player = info["touched"]
		
		_toucher.start_dying(user.get_eyes_reference())
		state_machine.change_state("KillState", {"to_look": _toucher})
		return

	if info.has("end"):
		user.end_buffered = true

	if info.has("located"):
		_navigation_agent_3d.target_position = info["located"]
		return

	if info.has("arrived"):
		state_machine.change_state("WanderingState", {"next_state": "ReturningState"})

func end() -> void:
	_is_active = false
