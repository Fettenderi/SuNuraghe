@tool
class_name Door
extends Node3D

const ARRIVED_THRESHOLD = 0.01

@export var bake_override := false:
	set(value):
		bake_override = value
		_set_bake_mode(value)

@export var is_open := false:
	set(value):
		is_open = value
		_set_open(value)

@export var is_locked := false

@export var lock_receiver_resource : ReceiverRes
@export var open_receiver_resource : ReceiverRes
@export var close_receiver_resource : ReceiverRes

@export var strattle_emitter_resource : EmitterRes

@onready var _mesh: Node3D = %Mesh
@onready var _interactable_box: InteractableBox = %InteractableBox

var _target_rotation := 0.0
var _arrived := true

var _max_vibrating_time := 0.4
var _vibrating_time := 0.0
var _vibration_angle := PI / 16
var _vibration_amount := 2

func _ready() -> void:
	_set_open(is_open or bake_override)
	if Engine.is_editor_hint(): return
	
	if not is_locked:
		_interactable_box.state = is_open
	
	if lock_receiver_resource != null:
		lock_receiver_resource.received.connect((func(): is_locked = not is_locked).unbind(1))
	if open_receiver_resource != null:
		open_receiver_resource.received.connect((func(): is_open = true).unbind(1))
	if close_receiver_resource != null:
		close_receiver_resource.received.connect((func(): is_open = false).unbind(1))

func _set_open(value : bool) -> void:
	if Engine.is_editor_hint():
		if _mesh != null:
			_mesh.rotation.y = PI / 2 if value else 0.0
	else:
		_arrived = false
		_target_rotation = PI / 2 if value else 0.0

func _set_bake_mode(value : bool) -> void:
	_mesh.position.y = -2.65 if value else 0.0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _arrived: return
	
	if _vibrating_time > 0.0:
		_vibrating_time -= delta
	
	_mesh.rotation.y = lerp_angle(_mesh.rotation.y, _target_rotation +  _vibration_angle * sin(_vibration_amount * TAU * _vibrating_time / _max_vibrating_time), 1 - exp(-2.0 * delta))
	
	if _vibrating_time <= 0.0 and abs(_mesh.rotation.y - _target_rotation) <= ARRIVED_THRESHOLD:
		_arrived = true

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if is_locked:
		_vibrating_time = _max_vibrating_time
		_arrived = false
		if strattle_emitter_resource != null:
			strattle_emitter_resource.send_signal()
		return
	
	is_open = not is_open
