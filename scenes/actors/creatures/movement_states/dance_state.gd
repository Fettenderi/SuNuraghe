extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

@export_subgroup("Little Jump Configuration")
@export var little_jump_time := 1.5
@export var little_jump_speed := 4.0
@export var little_jump_factor := 1.0
@export var swings := 2.0
@export var swing_angle := PI / 2

@export_subgroup("Dance Configuration")
@export var max_suspects := 3

#@export var normal_jump_cooldown := 1.4
#@export var normal_jumps := 7
#@export var short_jump_cooldown := 0.5
#@export var short_jumps := 3
#@export var short_jumps := 3

var _is_active := false

var _leader := false

var _left_look := true
var _right_handed := true

#var _little_jump_cooldown : Timer
var _starting_rotation : float

var _navigation_agent_3d : NavigationAgent3D
var _waypoints : Array[Marker3D]
var _waypoint_progress := 0

var _receiver : ReceiverRes
var _emitter : EmitterRes:
	set(value):
		_emitter = value

var _suspect_level := 0

var _on_delay := false 
var _delay_timer : Timer 

var _increment_progress_counter := false

func start(info : Dictionary = {}) -> void:
	_is_active = true
	_increment_progress_counter = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d

	user.is_manual_jumping = true
	user.set_jump_delay(0.1)

	if info.has(&"waypoints"):
		var _container : Node = user.get_node(info[&"waypoints"])
		
		if _container == null:
			print(user.name + " NON HA UN NODEPATH ASSOLUTO")
		else:
			for _child : Node3D in _container.get_children():
				if _child is Marker3D:
					_waypoints.append(_child)
			
			_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
	
	if info.has(&"await"):
		_receiver = info[&"await"]
		
		_delay_timer = Utils.timer(1.0, _delay_ended, _delay_timer)
		
		if not _delay_timer.is_inside_tree():
			add_child(_delay_timer, true)
		
		_delay_timer.start()
		_on_delay = true

		if not _receiver.received.is_connected(_on_received_signal):
			_receiver.received.connect(_on_received_signal)
	
	if info.has(&"emitter"):
		_emitter = info[&"emitter"]

	
	if info.has(&"leader"):
		_leader = info[&"leader"]
	
	if info.has(&"speed"):
		max_speed = info[&"speed"]

	user.max_speed = max_speed
	user.change_rate = change_rate

	if info.has(&"right_handed"):
		_right_handed = info[&"right_handed"]

func update(info : Dictionary = {}) -> void:
	if not _is_active: return
	
	if info.has(&"touched"):
		get_tree().call_group(&"Enemy", "suspect_player")
		return

	if info.has(&"bell_note"):
		_starting_rotation = user.mesh.rotation.y
		user.make_jump()
		_tween_rotation()

	if info.has(&"suspect"):
		if info.has(&"final") and info[&"final"]:
			state_machine.change_state(&"StareState")
			return
		
		if not user.can_suspect: return
			
		_suspect_level += 1
		if _suspect_level >= max_suspects:
			state_machine.change_state(&"ChaseState", {&"located": user.target.global_position})
		else:
			state_machine.change_state(&"StareState", {&"next_state": &"DanceState", &"time": 2.0})


	if info.has(&"arrived"):
		if _increment_progress_counter:
			_waypoint_progress += 1
		
		if _waypoint_progress < len(_waypoints):
			_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
		else:
			_increment_progress_counter = false
			if _emitter != null:
				var _prev_emitter := _emitter
				_emitter.send_signal(true)
				if _prev_emitter == _emitter:
					_emitter = null
		
			if not _is_active: return
		
			if _receiver != null: return
			
			user.progress()

	if info.has(&"end"):
		user.end_buffered = true


func _tween_rotation():
	var tween := create_tween()
	tween.tween_method(_rotation_function, 0.0, little_jump_time, little_jump_time)
	_left_look = not _left_look

func _rotation_function(elapsed : float):
	user.mesh.rotation.y = (swing_angle / 2) * sin(-(1.0 if _left_look == _right_handed else -1.0) * swings * 2 * PI * elapsed / little_jump_time) + _starting_rotation

func end() -> void:
	_is_active = false
	_increment_progress_counter = false
	user.mesh.rotation.y = _starting_rotation
	if _delay_timer != null:
		_delay_timer.stop()
	
	user.is_manual_jumping = false

func _on_received_signal(_value) -> void:
	if not _is_active or _on_delay: return
	
	_receiver.received.disconnect(_on_received_signal)
	_receiver = null
	
	user.progress()

func _delay_ended() -> void:
	_on_delay = false
