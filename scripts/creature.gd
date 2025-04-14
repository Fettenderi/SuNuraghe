class_name Creature
extends CharacterBody3D

const MASS = 80.0
const TURNING_SPEED = 6.0

@export var verbose := false

@export var activation_receiver : ReceiverRes
@export var deactivation_receiver : ReceiverRes

@export var target : CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var movement_state_machine: StateMachine = %MovementSM
@onready var kill_box: ExpandedHitBox = %KillBox
@onready var mesh: Node3D = %Mesh
@onready var _footsteps_player: AdvancedSoundPlayer = %SFXFootsteps

@onready var _collision_shape: CollisionShape3D = %CollisionShape
@onready var _eyes: Node3D = %Eyes
@onready var _head: Node3D = %Head
@onready var jumpscare_position: Marker3D = %JumpscarePosition

@onready var _mamuthon: Node3D = %Mamuthon
@onready var _mamuthon_animator: AnimationPlayer = _mamuthon.get_node("AnimationPlayer")
@onready var _sfx_voice: FmodEventEmitter3D = %SFXVoices
@onready var _sfx_jumpscare: FmodEventEmitter3D = %SFXJumpscare
@onready var _jumpscare_light: OmniLight3D = %JumpscareLight

var end_buffered := false
var max_speed := 0.0
var speed_debufs := 0.0
var speed := 0.0
var change_rate := 1.0

var interrupted_state : StringName

var _acceleration := 12.0

var _is_active := false:
	set(value):
		_is_active = value
		_collision_shape.set_deferred("disabled", not value)
		if value:
			_voices_timer.start(max(randfn(15.0, 2.0), 0.0))
		visible = value

var _direction : Vector3

var can_kill := true
var can_suspect := true

var _can_start_movement := false

var _voices_timer : Timer

func _ready() -> void:
	if activation_receiver != null:
		_is_active = false
		activation_receiver.received.connect(_start_movement.unbind(1))
	else:
		_can_start_movement = true
	
	if deactivation_receiver != null:
		deactivation_receiver.received.connect(_end_movement.unbind(1))

	_voices_timer = Utils.timer(1.0, _emit_voice)
	add_child(_voices_timer, true)

	navigation_agent_3d.navigation_finished.connect(_on_navigation_finished)
	_eyes.create_rays(self)
	
	movement_state_machine.verbose = verbose

	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	
	_local_destination.y = 0.0
	
	if not navigation_agent_3d.is_target_reached():
		_direction = _local_destination.normalized()
		
		if _direction.length_squared() > 0.0:
			global_rotation.y = lerp_angle(global_rotation.y, atan2(_direction.x, _direction.z), 1.0 - exp(-TURNING_SPEED * delta))
			_footsteps_player.playing_period = max_speed * 1.5
			_footsteps_player.request_playing()
	
	Utils.update_just_speed(self, change_rate, max_speed + speed_debufs, delta)
	
	velocity.x = move_toward(velocity.x, _direction.x * speed, _acceleration * delta)
	velocity.z = move_toward(velocity.z, _direction.z * speed, _acceleration * delta)
	
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
		if not _collision.get_collider() is RigidBody3D: continue
		
		_push_direction = -_collision.get_normal()
		_velocity_difference = max(velocity.dot(_push_direction) - _collision.get_collider().linear_velocity.dot(_push_direction), 0.0)
		_push_direction.y = 0.0
		
		_mass_ratio = min(MASS / _collision.get_collider().mass, 1.0)
		_push_force = _mass_ratio * 0.9
		
		_collision.get_collider().apply_impulse(_push_direction * _velocity_difference * _push_force, _collision.get_position() - _collision.get_collider().global_position)

func _start_movement() -> void:
	_is_active = true
	movement_state_machine.start()
	
	LevelStats.level_data.set_value(Utils.nhash(self) + &"active", true)

func _end_movement() -> void:
	movement_state_machine.update({"end": true})
	
	LevelStats.level_data.set_value(Utils.nhash(self) + &"active", false)

func _on_eyes_located(collider: Player) -> void:
	if not _is_active: return
	
	if target == null:
		target = collider
	
	interrupted_state = movement_state_machine.current_state.name
	
	movement_state_machine.update({"located": collider.global_position, "is_disguised": collider.is_disguised()})

func _on_kill_box_body_entered(body: Node3D) -> void:
	if not _is_active: return
	
	movement_state_machine.update({"touched" : body, "can_kill" : can_kill})
	
	target = body


func _on_navigation_finished():
	_direction = Vector3.ZERO
	movement_state_machine.update({"arrived" : true})

func get_eyes_reference() -> Node3D:
	return _head

func suspect_player(final := false) -> void:
	movement_state_machine.update({"suspect" : true, "final" : final})

func look(target_position : Node3D, delta : float) -> void:
	var _local_destination := target_position.global_position - global_position
	var _local_direction := _local_destination.normalized()
	
	global_rotation.y = lerp_angle(global_rotation.y, atan2(_local_direction.x, _local_direction.z), 1.0 - exp(-TURNING_SPEED * delta))

func do_kill_animation() -> void:
	if not target is Player or not can_kill: return
	
	_jumpscare_light.visible = true
	_mamuthon_animator.play("FaceAction")
	_sfx_jumpscare.play() #(1.1666)

func _emit_voice() -> void:
	_sfx_voice.play()
	_voices_timer.start(max(randfn(15.0, 2.0), 0.0))

func _load_data(data : GStorage) -> void:
	if data.has_value(Utils.nhash(self) + &"active"):
		if data.get_value(Utils.nhash(self) + &"active"): _start_movement()
		else: queue_free()
	else:
		if _can_start_movement:
			_start_movement()

func _save_data(data : GStorage) -> void:
	if _is_active:
		data.set_value(Utils.nhash(self) + &"active", true)


func _on_sfx_footsteps_plays() -> void:
	var tween := create_tween()
	
	tween.tween_method(_little_dance, 0.0, 0.8, 0.8)

func _little_dance(elapsed):
	mesh.position.y = 0.25 * _roof_function(elapsed)
	speed_debufs = - 0.6 * _roof_function(elapsed) * max_speed

func _roof_function(value : float):
	return max(2.0 * (0.8 - abs((value - 0.8) * (value - 0.8) * 2.5 - 0.8)), 0.0)
