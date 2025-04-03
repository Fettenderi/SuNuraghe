class_name Player
extends CharacterBody3D

const MASS = 80.0
const TURNING_SPEED = 6.0

const HEAD_ROTATION_MIN = -90.0
const HEAD_ROTATION_MAX = 90.0

const KEY_BIND_FORWARD = "move_forward"
const KEY_BIND_LEFT = "move_left"
const KEY_BIND_RIGHT = "move_right"
const KEY_BIND_BACKWARD = "move_backward"
const KEY_BIND_JUMP = "jump"
const KEY_BIND_COVER = "cover"
const KEY_BIND_SPRINT = "sprint"
const KEY_BIND_NOCLIP = "noclip"


@export_subgroup("Movement")
@export var acceleration := 50.0
@export var in_air_acceleration := 5.0
@export var jump_velocity := 4.5
@export var backward_speed_factor := 0.5
@export_subgroup("Mouse")
@export var mouse_sentitivity := 0.002
@export var mouse_acceleration := 50

@onready var camera_3d: Camera3D = $Head/Camera3D

@onready var _head: Node3D = %Head
@onready var sound_maker: ExpandedHitBox = %SoundMaker

@onready var movement_sm: StateMachine = %MovementSM
@onready var stamina_sm: StateMachine = %StaminaSM
@onready var shape_controller: ShapeController = %ShapeController

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var max_speed : float
var stamina : float
var head_bob_frequency := 0.3
var head_bob_amplitude := 0.01
var head_start_pos : Vector3

var _accel := acceleration

var _rotation_target_player : float
var _rotation_target_head : float
var _head_bob_tick := 0

var jump_buffered := false:
	set(value):
		jump_buffered = value
		
		if value: %JumpBuffer.start()

func _ready() -> void:
	if Engine.is_editor_hint(): return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	head_start_pos = _head.position
	_rotation_target_player = quaternion.get_angle()
	PlayerStats.disguised_changed.connect(set_disguised)
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

func _usual_update(delta : float) -> void:
	if Engine.is_editor_hint(): return
	
	_head_bob_tick += 1
	
	_move_player(delta)
	rotate_player(delta)
	
	if velocity and is_on_floor():
		_head_bob_update()
	_reset_head_bob(delta)


func _input(event : InputEvent) -> void:
	if Engine.is_editor_hint(): return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_set_rotation_target(event.relative)
	if event.is_action_released("debug"):
		get_tree().reload_current_scene()


func _move_player(delta : float) -> void:
	var _input_dir := Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_FORWARD, KEY_BIND_BACKWARD).normalized()
	var _backward_factor := (1.0 if _input_dir.y <= 0.0 else backward_speed_factor)
	var _direction := transform.basis * Vector3(-_input_dir.x, 0.0, -_input_dir.y) * _backward_factor

	if not is_on_floor():
		_accel = in_air_acceleration
		
		velocity.y -= _gravity * delta
	else:
		_accel = acceleration
		#_sound_maker.set_enabled(false)
	
	velocity.x = move_toward(velocity.x, _direction.x * max_speed, _accel * delta)
	velocity.z = move_toward(velocity.z, _direction.z * max_speed, _accel * delta)

	_collide_with_rigidbodies()

	move_and_slide()

func rotate_player(delta : float) -> void:
	quaternion = quaternion.slerp(Quaternion(Vector3.UP, _rotation_target_player), mouse_acceleration * delta)
	
	_head.quaternion = _head.quaternion.slerp(Quaternion(Vector3.LEFT, _rotation_target_head), mouse_acceleration * delta)

func _set_rotation_target(mouse_motion : Vector2) -> void:
	_rotation_target_player += -mouse_motion.x * mouse_sentitivity
	_rotation_target_head += -mouse_motion.y * mouse_sentitivity
	
	_rotation_target_head = clamp(_rotation_target_head, deg_to_rad(HEAD_ROTATION_MIN), deg_to_rad(HEAD_ROTATION_MAX))

func _head_bob_update() -> void:
	var _pos := Vector3.ZERO
	
	_pos.y += sin(_head_bob_tick * head_bob_frequency) * head_bob_amplitude
	_pos.x += cos(_head_bob_tick * head_bob_frequency / 2) * head_bob_amplitude * 2
	
	_head.position += _pos

func _reset_head_bob(delta : float) -> void:
	if _head.position == head_start_pos: return
	
	_head.position = lerp(_head.position, head_start_pos, 2 * (1 / head_bob_frequency) * delta)

func _on_jump_buffer_timeout() -> void:
	jump_buffered = false

func _collide_with_rigidbodies():
	var _collision : KinematicCollision3D
	var _push_direciton : Vector3
	var _push_force : float
	var _velocity_difference : float
	var _mass_ratio : float
	
	for _collision_index in get_slide_collision_count():
		_collision = get_slide_collision(_collision_index)
		if _collision.get_collider() is RigidBody3D:
			_push_direciton = -_collision.get_normal()
			_velocity_difference = max(velocity.dot(_push_direciton) - _collision.get_collider().linear_velocity.dot(_push_direciton), 0.0)
			_push_direciton.y = 0.0
			
			_mass_ratio = min(MASS / _collision.get_collider().mass, 1.0)
			_push_force = _mass_ratio * 0.9
			
			_collision.get_collider().apply_impulse(_push_direciton * _velocity_difference * _push_force, _collision.get_position() - _collision.get_collider().global_position)

func start_dying(to_look : Vector3):
	movement_sm.change_state("DieState", {"to_look": to_look})

func set_disguised(value : bool) -> void:
	if value: movement_sm.change_state("DisguisedState")
	else: movement_sm.change_state("WalkState")

func is_disguised() -> bool:
	return PlayerStats.disguised

func look(target : Vector3, delta : float) -> void:
	var _local_destination := target - global_position
	var _local_direction := _local_destination.normalized()
	
	quaternion = quaternion.slerp(Quaternion(Vector3.UP, atan2(_local_direction.x, _local_direction.z)), mouse_acceleration * delta)
	_head.quaternion = _head.quaternion.slerp(Quaternion(Vector3.LEFT, atan2(_local_direction.z, _local_direction.y)), mouse_acceleration * delta)

func _load_data(data : GStorage) -> void:
	global_position = Utils.string_to_vector3(data.get_value(&"player_" + &"position"))
	
	var _rot_vector : Vector4 = Utils.string_to_vector4(data.get_value(&"player_" + &"rotation"))
	_rotation_target_player = sign(_rot_vector.x) * Quaternion(0.0, _rot_vector.x, 0.0, _rot_vector.y).get_angle()
	_rotation_target_head = - sign(_rot_vector.z) * Quaternion(_rot_vector.z, 0.0, 0.0, _rot_vector.w).get_angle()
	
	PlayerStats.wool_pieces = data.get_value(&"player_" + &"wool_pieces")
	PlayerStats.disguised = data.get_value(&"player_" + &"disguised")


func _save_data(data : GStorage) -> void:
	data.set_value(&"player_" + &"position", global_position)
	data.set_value(&"player_" + &"rotation", Vector4(quaternion.y, quaternion.w, _head.quaternion.x, _head.quaternion.w))
	
	data.set_value(&"player_" + &"wool_pieces",PlayerStats.wool_pieces)
	data.set_value(&"player_" + &"disguised", PlayerStats.disguised)
