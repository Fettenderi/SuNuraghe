extends CharacterBody3D

const TURNING_SPEED = 6.0

@export var verbose := false

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var mesh: Node3D = %Mesh

var max_speed := 300.0

var _direction : Vector3

func _ready() -> void:
	navigation_agent_3d.target_position = global_position + basis * Vector3(0.0, 0.0, 10.0)
	
	navigation_agent_3d.navigation_finished.connect(_on_navigation_finished)


func _physics_process(delta: float) -> void:
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	_local_destination.y = 0.0
	
	if not navigation_agent_3d.is_target_reached():
		_direction = _local_destination.normalized()
		
		global_rotation.y = lerp_angle(global_rotation.y, atan2(_direction.x, _direction.z), 1.0 - exp(-TURNING_SPEED * delta))
	
	velocity = velocity.move_toward(_direction * max_speed * delta, 0.25)
	
	move_and_slide()

func _on_navigation_finished():
	_direction = Vector3.ZERO
	print("Finito")


func look(target_position : Vector3, delta : float) -> void:
	var _local_destination := target_position - global_position
	var _local_direction := _local_destination.normalized()
	
	global_rotation.y = lerp_angle(global_rotation.y, atan2(_local_direction.x, _local_direction.z), 1.0 - exp(-TURNING_SPEED * delta))
