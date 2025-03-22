extends State

@export var speed := 200.0
@export var distance := 10.0

var _is_active := false

var _target : CharacterBody3D
var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	user.speed = speed
	
	if info.has("located"):
		if _target == null:
			_target = user.target

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		user.end_buffered = true

	if info.has("located"):
		if _target == null:
			_target = user.target

func end() -> void:
	_is_active = false


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	if _target == null: return
	
	user.look(_target.position, delta)
	_navigation_agent_3d.target_position = _get_actual_target_position(_target.position)

func _get_actual_target_position(target_position : Vector3) -> Vector3:
	if (user.position - target_position).length() > distance:
		return target_position
	return user.position
