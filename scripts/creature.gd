class_name Creature
extends CharacterBody3D

const TURNING_SPEED = 6.0

@export var distance_threshold := 0.5

@export var activation_receiver : ReceiverRes
@export var deactivation_receiver : ReceiverRes

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var movement_state_machine: StateMachine = %MovementSM

@onready var _world_collision_shape: CollisionShape3D = %WorldCollisionShape
@onready var _agents_collision_shape: CollisionShape3D = %AgentsCollisionShape
@onready var _mesh: Node3D = %Mesh
@onready var _eyes: Node3D = %Eyes
@onready var _head: Node3D = %Head

var end_buffered := false
var speed := 0.0

var _is_active := false:
	set(value):
		_is_active = value
		_world_collision_shape.set_deferred("disabled", not value)
		_agents_collision_shape.set_deferred("disabled", not value)
		visible = value

var _direction : Vector3

var _arrived_cooldown : Timer
var _on_arrived_cooldown := false:
	set(value):
		if _on_arrived_cooldown == value: return
		
		_on_arrived_cooldown = value
		if _on_arrived_cooldown: _arrived_cooldown.start()

var target : CharacterBody3D

func _ready() -> void:
	if activation_receiver != null:
		_is_active = false
		activation_receiver.received.connect(_start_movement.unbind(1))
	else:
		_start_movement()
	
	if deactivation_receiver != null:
		deactivation_receiver.received.connect(_end_movement.unbind(1))

	_setup_arrived_cooldown()
	_eyes.create_rays(self)

func _physics_process(delta: float) -> void:
	#movement_state_machine.update()
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	
	if Vector2(_local_destination.x, _local_destination.z).length() > distance_threshold:
		_direction = _local_destination.normalized()
		
		_mesh.global_rotation.y = lerp_angle(_mesh.global_rotation.y, atan2(_direction.x, _direction.z), 1.0 - exp(-TURNING_SPEED * delta))
	elif not _on_arrived_cooldown:
		_on_arrived_cooldown = true
		_direction = Vector3.ZERO
		movement_state_machine.update({"arrived" : true})
	
	velocity = _direction * speed * delta
	
	move_and_slide()

func _start_movement() -> void:
	_is_active = true
	movement_state_machine.start()

func _end_movement() -> void:
	movement_state_machine.update({"end": true})
	queue_free()

func _on_eyes_located(collider: Player) -> void:
	if not _is_active: return
	
	target = collider
	
	movement_state_machine.update({"located": collider.global_position})

func _on_kill_box_body_entered(body: Node3D) -> void:
	if not _is_active: return
	
	movement_state_machine.change_state("KillingState", {"to_look" : body.global_position})
	
	if body is Player:
		body.start_dying(_head.global_position)
	navigation_agent_3d.target_position = body.global_position

func _setup_arrived_cooldown() -> void:
	_arrived_cooldown = Timer.new()
	_arrived_cooldown.one_shot = true
	_arrived_cooldown.autostart = false
	_arrived_cooldown.wait_time = 0.3
	_arrived_cooldown.timeout.connect(_arrived_cooldown_ended)
	add_child(_arrived_cooldown, true)

func _arrived_cooldown_ended() -> void:
	_on_arrived_cooldown = false

func look(target_position : Vector3, delta : float) -> void:
	var _local_destination := target_position - global_position
	var _local_direction := _local_destination.normalized()
	
	_mesh.global_rotation.y = lerp_angle(_mesh.global_rotation.y, atan2(_local_direction.x, _local_direction.z), 1.0 - exp(-TURNING_SPEED * delta))
