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
@export var normal_jump_cooldown := 1.4
@export var normal_jumps := 7
@export var short_jump_cooldown := 0.5
@export var short_jumps := 3

var _is_active := false

var _leader := false

var _dance_progress := 0
var _center_direction := Vector3.LEFT

var _little_jumping := false
var _little_jump_elapsed := 0.0
var _little_jump_cooldown : Timer
var _starting_rotation : float

var _navigation_agent_3d : NavigationAgent3D
var _waypoints : Array[Marker3D]
var _waypoint_progress := 0

var _receiver : ReceiverRes
var _emitter : EmitterRes

var _suspect_level := 0

var _on_delay := false 
var _delay_timer : Timer 

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	_little_jump_cooldown = Utils.timer(normal_jump_cooldown, _on_little_jump_cooldown_timeout, _little_jump_cooldown)
	
	if not _little_jump_cooldown.is_inside_tree():
		add_child(_little_jump_cooldown, true)
		
	_little_jump_cooldown.start()

	if info.has("waypoints"):
		var _container : Node = user.get_node(info["waypoints"])
		
		if _container == null:
			print(user.name + " NON HA UN NODEPATH ASSOLUTO")
		else:
			for _child : Node3D in _container.get_children():
				if _child is Marker3D:
					_waypoints.append(_child)
			
			_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
	
	if info.has("await"):
		_receiver = info["await"]
		
		_delay_timer = Utils.timer(1.0, _delay_ended, _delay_timer)
		
		if not _delay_timer.is_inside_tree():
			add_child(_delay_timer, true)
		
		_delay_timer.start()
		_on_delay = true

		if not _receiver.received.is_connected(_on_received_signal):
			_receiver.received.connect(_on_received_signal)
	
	if info.has("emitter"):
		_emitter = info["emitter"]

	
	if info.has("leader"):
		_leader = info["leader"]
	
	if info.has("speed"):
		max_speed = info["speed"]

	user.max_speed = max_speed
	user.change_rate = change_rate

	if info.has("center"):
		_center_direction = info["center"]

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		get_tree().call_group(&"Enemy", "suspect_player")
		return

	if info.has("suspect"):
		if info.has("final") and info["final"]:
			state_machine.change_state("StareState")
			return
		
		if not user.can_suspect: return
			
		_suspect_level += 1
		if _suspect_level >= max_suspects:
			state_machine.change_state("ChaseState", {"located": user.target.global_position})
		else:
			state_machine.change_state("StareState", {"next_state": "DanceState", "time": 2.0})


	if info.has("arrived"):
		_waypoint_progress += 1
		
		if _waypoint_progress < len(_waypoints):
			_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
		else:
			if _emitter != null:
				_emitter.send_signal(true)
				_emitter = null
		
			if _receiver != null: return
			
			user.progress()

	if info.has("end"):
		user.end_buffered = true

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	if _little_jumping: _handle_jumping(delta)
	else: _handle_walking(delta)


func _handle_jumping(delta : float) -> void:
	_little_jump_elapsed += delta
	user.max_speed = 0.0
	#Utils.update_just_speed(user, change_rate, 0.0, delta)
	user.mesh.rotation.y = (swing_angle / 2) * sin((1.0 if _dance_progress % 2 == 0 else -1.0) * swings * 2 * PI * _little_jump_elapsed / little_jump_time) + _starting_rotation
	user.mesh.position.y = lerp(user.mesh.position.y, little_jump_factor * _roof_function(_little_jump_elapsed, little_jump_time), 1.0 - exp(-delta * little_jump_speed))
	if _little_jump_elapsed >= little_jump_time:
		_little_jumping = false


func _handle_walking(delta : float) -> void:
	user.mesh.position.y = lerp(user.mesh.position.y, 0.0, 1.0 - exp(-delta * little_jump_speed))
	user.max_speed = max_speed
	#Utils.update_just_speed(user, change_rate, max_speed, delta)

func _roof_function(value : float, center : float):
	return max(2.0 * (center - abs(value * 2.0 - center)), 0.0)


func _on_little_jump_cooldown_timeout():
	_little_jump_elapsed = 0.0
	_starting_rotation = user.mesh.rotation.y
	_little_jumping = true
	_dance_progress += 1
	
	if _leader:
		TimeKeeper.dance_input()
	
	if _dance_progress <= normal_jumps:
		_little_jump_cooldown.start(normal_jump_cooldown)
	elif _dance_progress <= normal_jumps + short_jumps - 1:
		_little_jump_cooldown.start(short_jump_cooldown)
	else:
		_little_jump_cooldown.start(normal_jump_cooldown)
		_dance_progress = 0
		

func end() -> void:
	_is_active = false
	_little_jumping = false
	_little_jump_cooldown.stop()
	user.mesh.rotation.y = _starting_rotation
	user.mesh.position.y = 0.0
	_little_jump_elapsed = 0.0
	if _delay_timer != null:
		_delay_timer.stop()

func _on_received_signal(_value) -> void:
	if not _is_active or _on_delay: return
	
	_receiver.received.disconnect(_on_received_signal)
	_receiver = null
	
	user.progress()

func _delay_ended() -> void:
	_on_delay = false
