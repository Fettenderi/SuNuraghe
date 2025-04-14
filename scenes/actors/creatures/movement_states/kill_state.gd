extends State

@export var change_rate := 1.0

var _is_active := false
var _stare_target : Node3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	user.do_kill_animation()
	user.navigation_agent_3d.target_position = user.position
	
	user.max_speed = 0.0
	user.change_rate = change_rate
	
	state_machine.stop()
	if info.has("to_look"):
		_stare_target = info["to_look"]

func end() -> void:
	_is_active = false

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	user.look(_stare_target, delta)
	_stare_target.global_position = lerp(_stare_target.global_position, user.jumpscare_position.global_position - Vector3(0.0, 1.662, 0.0), 1.0 - exp(-5.0 * delta))
	
	#Utils.update_just_speed(user, change_rate, 0.0, delta)
