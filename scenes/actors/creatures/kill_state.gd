extends State

var _is_active := false
var _stare_target : Vector3

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	user.navigation_agent_3d.target_position = user.position
	
	state_machine.stop()
	if info.has("to_look"):
		_stare_target = info["to_look"]

func end() -> void:
	_is_active = false

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	user.look(_stare_target, delta)
