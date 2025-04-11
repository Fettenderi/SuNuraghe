extends State

const STARE_TIME = 1.75

var _stare_timer : Timer

var _is_active := false
var _stare_target : Node3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	#state_machine.change_state("WalkState")
	state_machine.stop()
	
	_stare_timer = Utils.timer(STARE_TIME, _on_stare_timer_ended, _stare_timer)
	add_child(_stare_timer, true)
	
	_stare_timer.start()

	if info.has("to_look"):
		_stare_target = info["to_look"]

func end() -> void:
	_is_active = false

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	user.look(_stare_target, delta)

func _on_stare_timer_ended() -> void:
	if not _is_active: return
	
	get_tree().call_deferred("reload_current_scene")
