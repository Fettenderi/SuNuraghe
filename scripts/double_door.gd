@tool
class_name DoubleDoor
extends Node3D

const ARRIVED_THRESHOLD = 0.01

#@export var bake_override := false:
	#set(value):
		#if not Engine.is_editor_hint() or not is_inside_tree(): return
#
		#bake_override = value
		#_set_bake_mode(value)

@export var is_open := false:
	set(value):
		is_open = value
		_set_open(value)

@export var receiver_resource : ReceiverRes
@export var strattle_emitter_resource : EmitterRes
@export var rebake_emitter : EmitterRes

@onready var _mesh_right: Node3D = %MeshRight
@onready var _mesh_left: Node3D = %MeshLeft
@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _sfx_emitter: FmodEventEmitter3D = %SFXEmitter

var _right_target_rotation := PI / 2
var _left_target_rotation := 0.0
var _arrived := true

var _max_vibrating_time := 0.4
var _vibrating_time := 0.0
var _vibration_angle := PI / 16
var _vibration_amount := 2

func _ready() -> void:
	_set_open(is_open, true)
	if Engine.is_editor_hint(): return
	_mesh_right.position.y = 0.0
	_mesh_left.position.y = 0.0
	
	if receiver_resource == null:
		_interactable_box.state = is_open
	else:
		receiver_resource.received.connect((func(): is_open = not is_open).unbind(1))
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _set_open(value : bool, bypass := false):
	if Engine.is_editor_hint() or bypass:
		if _mesh_right != null:
			_mesh_right.rotation.y = 0.0 if value else - PI / 2
		if _mesh_left != null:
			_mesh_left.rotation.y = PI if value else - PI / 2
	else:
		if _sfx_emitter != null:
			_sfx_emitter.play()
		_arrived = false
		_right_target_rotation = 0.0 if value else - PI / 2
		_left_target_rotation = PI if value else - PI / 2

func _set_bake_mode(value : bool) -> void:
	_mesh_right.position.y = -2.65 if value else 0.0
	_mesh_left.position.y = -2.65 if value else 0.0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if _arrived: return
	
	if _vibrating_time > 0.0:
		_vibrating_time -= delta
	
	_mesh_right.quaternion = _mesh_right.quaternion.slerp(Quaternion(Vector3.UP, _right_target_rotation +  _vibration_angle * sin(_vibration_amount * TAU * _vibrating_time / _max_vibrating_time)), 1 - exp(-2.0 * delta))
	_mesh_left.quaternion = _mesh_left.quaternion.slerp(Quaternion(Vector3.UP, _left_target_rotation +  _vibration_angle * sin(_vibration_amount * TAU * _vibrating_time / _max_vibrating_time)), 1 - exp(-2.0 * delta))
	
	#_mesh_left.rotation.y = lerp_angle(_mesh_left.rotation.y, _left_target_rotation +  _vibration_angle * sin(_vibration_amount * TAU * _vibrating_time / _max_vibrating_time), 1 - exp(-2.0 * delta))
	
	
	if _vibrating_time <= 0.0 and abs(_mesh_right.rotation.y - _right_target_rotation) <= ARRIVED_THRESHOLD:
		_arrived = true
		
		if rebake_emitter != null:
			rebake_emitter.send_signal()

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if Engine.is_editor_hint(): return
	
	if receiver_resource != null:
		_vibrating_time = _max_vibrating_time
		_arrived = false
		if _sfx_emitter != null:
			_sfx_emitter.play()
			await get_tree().create_timer(0.3).timeout
			_sfx_emitter.stop()

		if strattle_emitter_resource != null:
			strattle_emitter_resource.send_signal()
		return
	
	is_open = not is_open

func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self) + &"is_open"): return
	
	is_open = bool(data.get_value(Utils.nhash(self) + &"is_open"))

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"is_open", is_open)
