class_name Player
extends CharacterBody3D


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
@onready var _sound_maker: ExpandedHitBox = %SoundMaker
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D


var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _max_speed : float
var _speed : float
var _accel := acceleration

var _rotation_target_player : float
var _rotation_target_head : float
var _head_start_pos : Vector3
var _head_bob_tick := 0

var _head_bob_frequency := 0.3
var _head_bob_amplitude := 0.01

var _jump_buffered := false:
	set(value):
		_jump_buffered = value
		
		if value: %JumpBuffer.start()


func _ready() -> void:
	if Engine.is_editor_hint(): return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	_head_start_pos = _head.position

func _usual_update(delta : float) -> void:
	if Engine.is_editor_hint(): return
	
	_head_bob_tick += 1
	
	_move_player(delta)
	_rotate_player(delta)
	
	if velocity and is_on_floor():
		_head_bob_update()
	_reset_head_bob(delta)


func _input(event : InputEvent) -> void:
	if Engine.is_editor_hint(): return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_set_rotation_target(event.relative)


func _move_player(delta : float) -> void:
	var _input_dir := Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_FORWARD, KEY_BIND_BACKWARD).normalized()
	var _backward_factor := (1.0 if _input_dir.y <= 0.0 else backward_speed_factor)
	var _direction := transform.basis * Vector3(_input_dir.x, 0.0, _input_dir.y) * _backward_factor

	if not is_on_floor():
		_speed = _max_speed
		_accel = in_air_acceleration
		
		velocity.y -= _gravity * delta
	else:
		_speed = _max_speed
		_accel = acceleration
		#_sound_maker.set_enabled(false)

	velocity.x = move_toward(velocity.x, _direction.x * _speed, _accel * delta)
	velocity.z = move_toward(velocity.z, _direction.z * _speed, _accel * delta)

	move_and_slide()

func _rotate_player(delta : float) -> void:
	quaternion = quaternion.slerp(Quaternion(Vector3.UP, _rotation_target_player), mouse_acceleration * delta)
	
	_head.quaternion = _head.quaternion.slerp(Quaternion(Vector3.RIGHT, _rotation_target_head), mouse_acceleration * delta)


func _set_rotation_target(mouse_motion : Vector2) -> void:
	_rotation_target_player += -mouse_motion.x * mouse_sentitivity
	_rotation_target_head += -mouse_motion.y * mouse_sentitivity
	
	_rotation_target_head = clamp(_rotation_target_head, deg_to_rad(HEAD_ROTATION_MIN), deg_to_rad(HEAD_ROTATION_MAX))

func _head_bob_update() -> void:
	var _pos := Vector3.ZERO
	
	_pos.y += sin(_head_bob_tick * _head_bob_frequency) * _head_bob_amplitude
	_pos.x += cos(_head_bob_tick * _head_bob_frequency / 2) * _head_bob_amplitude * 2
	
	_head.position += _pos

func _reset_head_bob(delta : float) -> void:
	if _head.position == _head_start_pos: return
	
	_head.position = lerp(_head.position, _head_start_pos, 2 * (1 / _head_bob_frequency) * delta)


func set_collision(value : bool) -> void:
	_collision_shape_3d.set_deferred("disabled", not value)

func _on_jump_buffer_timeout() -> void:
	_jump_buffered = false
