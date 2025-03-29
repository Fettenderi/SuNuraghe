extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

@export_subgroup("Little Jump Configuration")
@export var little_jump_cooldown := 1.0
@export var little_jump_time := 1.5
@export var little_jump_speed := 4.0
@export var little_jump_factor := 1.0

var _is_active := false

var _little_jumping := false
var _little_jump_elapsed := 0.0
var _little_jump_cooldown : Timer

var _navigation_agent_3d : NavigationAgent3D
var _waypoints : Array[Marker3D]
var _waypoint_progress := 0

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	_little_jump_cooldown = Utils.timer(little_jump_cooldown, _on_little_jump_cooldown_timeout, _little_jump_cooldown)
	
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
	
	if info.has("speed"):
		max_speed = info["speed"]

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		get_tree().call_group(&"Enemy", "look", info["touched"].global_position)
		print("AOO CHE TOCCHI " + user.name + " " + name)
		return

	if info.has("arrived"):
		_waypoint_progress += 1
		
		if _waypoint_progress < len(_waypoints):
			_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
		else:
			user.progress()

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	if _little_jumping: _handle_jumping(delta)
	else: _handle_walking(delta)
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)


func _handle_jumping(delta : float) -> void:
	_little_jump_elapsed += delta
	Utils.update_just_speed(user, change_rate, 0.0, delta)
	user.mesh.position.y = lerp(user.mesh.position.y, little_jump_factor * _roof_function(_little_jump_elapsed, little_jump_time), 1.0 - exp(-delta * little_jump_speed))
	if _little_jump_elapsed >= little_jump_time:
		_little_jumping = false


func _handle_walking(delta : float) -> void:
	user.mesh.position.y = lerp(user.mesh.position.y, 0.0, 1.0 - exp(-delta * little_jump_speed))

func _roof_function(value : float, center : float):
	return max(2.0 * (center - abs(value * 2.0 - center)), 0.0)


func _on_little_jump_cooldown_timeout():
	_little_jump_elapsed = 0.0
	_little_jumping = true
	_little_jump_cooldown.start()


func end() -> void:
	_is_active = false
