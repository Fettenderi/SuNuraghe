class_name Creature
extends CharacterBody3D

const MASS = 80.0
const TURNING_SPEED = 6.0

@export var verbose := false

@export var distance_threshold := 0.5

@export var activation_receiver : ReceiverRes
@export var deactivation_receiver : ReceiverRes

@export var target : CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var movement_state_machine: StateMachine = %MovementSM

@onready var _collision_shape: CollisionShape3D = %CollisionShape

@warning_ignore("unused_private_class_variable")
@onready var _mesh: Node3D = %Mesh
@onready var _eyes: Node3D = %Eyes
@onready var _head: Node3D = %Head

var end_buffered := false
var speed := 0.0

var interrupted_state : StringName

var _is_active := false:
	set(value):
		_is_active = value
		_collision_shape.set_deferred("disabled", not value)
		visible = value

var _direction : Vector3

var _arrived_cooldown : Timer
var _on_arrived_cooldown := false:
	set(value):
		if _on_arrived_cooldown == value: return
		
		_on_arrived_cooldown = value
		if _on_arrived_cooldown: _arrived_cooldown.start()

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
	
	movement_state_machine.verbose = verbose

func _physics_process(delta: float) -> void:
	#movement_state_machine.update()
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	_local_destination.y = 0.0
	
	if Vector2(_local_destination.x, _local_destination.z).length() > distance_threshold:
		_direction = _local_destination.normalized()
		
		global_rotation.y = lerp_angle(global_rotation.y, atan2(_direction.x, _direction.z), 1.0 - exp(-TURNING_SPEED * delta))
	elif not _on_arrived_cooldown:
		_on_arrived_cooldown = true
		_direction = Vector3.ZERO
		movement_state_machine.update({"arrived" : true})
	
	velocity = velocity.move_toward(_direction * speed * delta, 0.25)
	
	_collide_with_rigidbodies()
	
	move_and_slide()

func _collide_with_rigidbodies():
	var _collision : KinematicCollision3D
	var _push_direction : Vector3
	var _push_force : float
	var _velocity_difference : float
	var _mass_ratio : float
	
	for _collision_index in get_slide_collision_count():
		_collision = get_slide_collision(_collision_index)
		if _collision.get_collider() is RigidBody3D:
			_push_direction = -_collision.get_normal()
			_velocity_difference = max(velocity.dot(_push_direction) - _collision.get_collider().linear_velocity.dot(_push_direction), 0.0)
			_push_direction.y = 0.0
			
			_mass_ratio = min(MASS / _collision.get_collider().mass, 1.0)
			_push_force = _mass_ratio * 0.9
			
			_collision.get_collider().apply_impulse(_push_direction * _velocity_difference * _push_force, _collision.get_position() - _collision.get_collider().global_position)
		
		#if _collision.get_collider() is CharacterBody3D:
			#print("PING")
			#_push_direction = -_collision.get_normal()
			#_velocity_difference = max(velocity.dot(_push_direction) - _collision.get_collider().velocity.dot(_push_direction), 0.0)
			#_push_direction.y = 0.0
			#
			#_push_force = -5.0
			#
			#_collision.get_collider().velocity += _push_direction * _velocity_difference * _push_force
			##_collision.get_collider().apply_impulse(_push_direciton * _velocity_difference * _push_force, _collision.get_position() - _collision.get_collider().global_position)


func _start_movement() -> void:
	_is_active = true
	movement_state_machine.start()

func _end_movement() -> void:
	movement_state_machine.update({"end": true})
	queue_free()

func _on_eyes_located(collider: Player) -> void:
	if not _is_active: return
	
	if target == null:
		target = collider
	
	interrupted_state = movement_state_machine.current_state.name
	movement_state_machine.update({"located": collider.global_position, "is_disguised": collider.is_disguised()})

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
	
	global_rotation.y = lerp_angle(global_rotation.y, atan2(_local_direction.x, _local_direction.z), 1.0 - exp(-TURNING_SPEED * delta))
