extends State

const TARGET_SAMPLING_TIME = 1.5

@export var change_rate := 1.0

@export var max_speed := 200.0
@export var distance := 10.0

var _is_active := false

var _receiver : ReceiverRes
var _stare_timer : Timer

var _target : CharacterBody3D
var _navigation_agent_3d : NavigationAgent3D

var _target_sampling_elapsed := 0.0

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	_target = user.target
	_navigation_agent_3d.target_position = _get_actual_target_position(Vector3(_target.global_position.x, user.global_position.y,_target.global_position.z))
	
	if info.has(&"speed"):
		max_speed = info[&"speed"]
	
	user.max_speed = max_speed
	user.change_rate = change_rate

	if info.has(&"await"):
		_receiver = info[&"await"]
		_receiver.received.connect(_on_received_signal)
	else:
		_receiver = null

	if info.has(&"time"):
		_stare_timer = Utils.timer(info[&"time"], _on_stare_timer_ended, _stare_timer)
		
		if not _stare_timer.is_inside_tree():
			add_child(_stare_timer, true)
		
		_stare_timer.start()

func update(info : Dictionary = {}) -> void:
	if info.has(&"touched"):
		#print("AOO ARRASSATI " + user.name + " " + name)
		return

	if info.has(&"end"):
		user.end_buffered = true


func end() -> void:
	_is_active = false
	
	_navigation_agent_3d.target_position = user.global_position



func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_target_sampling_elapsed += delta
	
	if _target == null: return
	
	#Utils.update_just_speed(user, change_rate, max_speed, delta)
	
	user.look(_target, delta)
	
	_stop_if_near(Vector3(_target.global_position.x, user.global_position.y,_target.global_position.z))
	
	if _target_sampling_elapsed > TARGET_SAMPLING_TIME:
		_target_sampling_elapsed = 0.0
		_navigation_agent_3d.target_position = _get_actual_target_position(Vector3(_target.global_position.x, user.global_position.y,_target.global_position.z))
	

func _stop_if_near(target_position : Vector3):
	if (user.global_position - target_position).length() <= distance:
		_navigation_agent_3d.target_position = user.global_position

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
	
	_receiver.received.disconnect(_on_received_signal)
	
	user.progress()

func get_timer_progress() -> Dictionary:
	return {"time" : _stare_timer.time_left}
