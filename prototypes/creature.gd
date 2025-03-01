extends CharacterBody3D

@export var speed := 300.0
@export var distance_threshold := 0.5

@onready var _navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var _mesh: Node3D = %Mesh

@onready var _last_target_position := global_position

var _target : Node3D = null:
	set(value):
		_target = value
		_target_lost = _target == null

var _direction : Vector3

var _target_lost := false

func _physics_process(delta: float) -> void:
	var _target_position : Vector3
	
	if _target_lost:
		_target_position = _last_target_position
	else:
		if _target == null: return
		
		_target_position = _target.global_position
	
	
	_navigation_agent_3d.target_position = _target_position

	var destination := _navigation_agent_3d.get_next_path_position()
	var local_destination := destination - global_position
	
	if local_destination.length() > distance_threshold:
		_direction = local_destination.normalized()
		_mesh.rotation.y = atan2(_direction.x, _direction.z) - 1
		
		# Perchè devo sottrarre questo 1 arbitrario ???????????
	else:
		_direction = Vector3.ZERO
	
	velocity = _direction * speed * delta
	
	move_and_slide()


# Una volta raggiunga l'ultima posizione vista si guarda attorno 2 o 3 volte e poi torna alla sua postazione

func _on_ears_area_entered(area: Area3D) -> void:
	if area.is_in_group(&"Sound"):
		_target = area
	pass

func _on_eyes_located(collider) -> void:
	_target = collider
	_last_target_position = _target.global_position

func _on_eyes_not_visible() -> void:
	_target = null
