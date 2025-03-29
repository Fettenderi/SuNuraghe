extends State

@export var change_rate := 1.0

@export var max_speed := 200.0
@export var distance := 10.0

var _is_active := false

var _receiver : ReceiverRes
var _stare_timer : Timer

var _target : CharacterBody3D
var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	user.max_speed = max_speed
	
	_target = user.target
		
	if info.has("speed"):
		user.max_speed = info["speed"]
	
	if info.has("await"):
		_receiver = info["await"]
		_receiver.received.connect(_on_received_signal)
		return

	if info.has("time"):
		_stare_timer = Utils.timer(info["time"], _on_stare_timer_ended, _stare_timer)
		
		if not _stare_timer.is_inside_tree():
			add_child(_stare_timer, true)
		
		_stare_timer.start()

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		user.end_buffered = true


func end() -> void:
	_is_active = false
	
	_navigation_agent_3d.target_position = user.global_position


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	if _target == null: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)
	
	user.look(_target.global_position, delta)
	_navigation_agent_3d.target_position = _get_actual_target_position(_target.global_position)
	


func _get_actual_target_position(target_position : Vector3) -> Vector3:
	if (user.global_position - target_position).length() > distance:
		return target_position
	return user.global_position


func _on_stare_timer_ended() -> void:
	if not _is_active: return
	
	_stare_timer.stop()
	user.progress()

func _on_received_signal(_value) -> void:
	if not _is_active: return
	
	user.progress()
