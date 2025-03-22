@tool
class_name Creature
extends CharacterBody3D

const TURNING_SPEED = 10.0

@export_subgroup("Movement")
@export var distance_threshold := 0.5

@export var activation_receiver : ReceiverRes
@export var deactivation_receiver : ReceiverRes

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var _movement_state_machine: StateMachine = %MovementSM
@onready var _collision_shape: CollisionShape3D = %CollisionShape3D
@onready var _mesh: Node3D = %Mesh
@onready var _eyes: Node3D = %Eyes

var _is_active := false:
	set(value):
		_is_active = value
		_collision_shape.set_deferred("disabled", not value)
		visible = value
var speed := 0.0

var end_buffered := false

var _direction : Vector3

var _arrived_cooldown : Timer
var _on_arrived_cooldown := false:
	set(value):
		if _on_arrived_cooldown == value: return
		
		_on_arrived_cooldown = value
		if _on_arrived_cooldown: _arrived_cooldown.start()

func _ready() -> void:	
	if Engine.is_editor_hint(): return
	
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
	if Engine.is_editor_hint(): return
	
	_movement_state_machine.update()
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	
	if Vector2(_local_destination.x, _local_destination.z).length() > distance_threshold:
		_direction = _local_destination.normalized()
		
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, atan2(_direction.x, _direction.z), TURNING_SPEED * delta)
	elif not _on_arrived_cooldown:
		_on_arrived_cooldown = true
		_direction = Vector3.ZERO
		_movement_state_machine.update({"arrived" : true})
	
	velocity = _direction * speed * delta
	
	move_and_slide()


func _start_movement():
	_is_active = true
	_movement_state_machine.start()

func _end_movement():
	_movement_state_machine.update({"end": true})
	queue_free()

func _on_eyes_located(collider: Player) -> void:
	if not _is_active: return
	
	_movement_state_machine.update({"located": collider.position})


func _on_kill_box_body_entered(_body: Node3D) -> void:
	if not _is_active: return
	
	get_tree().call_deferred("reload_current_scene")
	#_movement_state_machine.change_state("KillingState")
	#if body is Player:
		#body.start_dying(position)
	#navigation_agent_3d.target_position = body.position

func _setup_arrived_cooldown():
	_arrived_cooldown = Timer.new()
	_arrived_cooldown.one_shot = true
	_arrived_cooldown.autostart = false
	_arrived_cooldown.wait_time = 0.3
	_arrived_cooldown.timeout.connect(_arrived_cooldown_ended)
	add_child(_arrived_cooldown, true)

func _arrived_cooldown_ended():
	_on_arrived_cooldown = false
