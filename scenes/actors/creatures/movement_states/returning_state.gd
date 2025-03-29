extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

var _is_active := false
var last_position : Vector3

func start(_info : Dictionary = {}) -> void:
	_is_active = true
	
	user.max_speed = max_speed

	user.navigation_agent_3d.target_position = last_position

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		user.end_buffered = true
	
	if info.has("located"):
		state_machine.change_state("ChaseState", {"located": info["located"]})
		return
	
	if info.has("arrived"):
		state_machine.change_state(user.interrupted_state)

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)

func end() -> void:
	_is_active = false
