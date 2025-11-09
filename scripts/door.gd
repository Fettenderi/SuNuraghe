@tool
class_name Door
extends Node3D

const ARRIVED_THRESHOLD = 0.01

@export var bake_override := false:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		
		bake_override = value
		_set_bake_mode(value)

@export var is_open := false:
	set(value):
		if is_open == value: return
			
		is_open = value
		_set_open(value)

@export var is_locked := false:
	set(value):
		is_locked = value
		_has_been_tampered = true

@export var lock_receiver_resource : ReceiverRes
@export var open_receiver_resource : ReceiverRes
@export var close_receiver_resource : ReceiverRes

@export var strattle_emitter_resource : EmitterRes

#@export var rebake_emitter : EmitterRes

@export var has_pressures := true

@export_flags_3d_physics var door_collision = 1

@onready var _mesh: Node3D = %Mesh
@onready var _collisions: StaticBody3D = %Collisions
@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _sfx_emitter: FmodEventEmitter3D = %SFXEmitter
#@onready var _navigation_link_3d: NavigationLink3D = %NavigationLink3D

var _target_rotation := 0.0
var _arrived := true

var _max_vibrating_time := 0.4
var _vibrating_time := 0.0
var _vibration_angle := PI / 16
var _vibration_amount := 2

var _open_angle := PI / 2 + PI / 8

var _player_near := false

var _has_been_tampered := false

func _ready() -> void:
	_set_open(is_open or bake_override, true)
	if Engine.is_editor_hint(): return
	_mesh.position.y = 0.0
	
	if not is_locked:
		_interactable_box.state = is_open
	
	if lock_receiver_resource != null:
		lock_receiver_resource.received.connect((func(): is_locked = not is_locked).unbind(1))
	if open_receiver_resource != null:
		open_receiver_resource.received.connect((func(): is_open = true).unbind(1))
	if close_receiver_resource != null:
		close_receiver_resource.received.connect((func(): is_open = false).unbind(1))
	
	if _collisions != null:
		_collisions.collision_layer = door_collision
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _set_open(value : bool, bypass : bool = false) -> void:
	if Engine.is_editor_hint() or bypass:
		if _mesh != null:
			_mesh.rotation.y = _open_angle if value else 0.0
		if _collisions != null:
			_collisions.rotation.y = _open_angle if value else 0.0
		#if _navigation_link_3d != null:
			#_navigation_link_3d.set_deferred("enabled", value)
		#if not Engine.is_editor_hint() and rebake_emitter != null:
			#rebake_emitter.send_signal()
	else:
		_has_been_tampered = true
		
		if _sfx_emitter != null:
			_sfx_emitter.play(0.2)
		_arrived = false
		_target_rotation = _open_angle if value else 0.0
		if _collisions != null:
			_collisions.rotation.y = _target_rotation
		
		#if _navigation_link_3d != null:
			#_navigation_link_3d.set_deferred("enabled", value)
		#if rebake_emitter != null:
			#rebake_emitter.send_signal()

func _set_bake_mode(value : bool) -> void:
	_collisions.rotation.y = _open_angle if (not value) else 0.0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _arrived: return
	
	if _vibrating_time > 0.0:
		_vibrating_time -= delta
	
	_mesh.rotation.y = lerp_angle(_mesh.rotation.y, _target_rotation +  _vibration_angle * sin(_vibration_amount * TAU * _vibrating_time / _max_vibrating_time), 1 - exp(-1.2 * delta))
	
	if _vibrating_time <= 0.0 and abs(_mesh.rotation.y - _target_rotation) <= ARRIVED_THRESHOLD:
		_arrived = true

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if is_locked:
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
	if not data.has_value(Utils.nhash(self)): return

	_has_been_tampered = true

	var loaded_data : Dictionary = data.get_value(Utils.nhash(self))
	is_open = loaded_data[&"is_open"]
	is_locked = loaded_data[&"is_locked"]

func _save_data(data : GStorage) -> void:
	if not _has_been_tampered: return
	
	data.set_value(Utils.nhash(self), {
		&"is_open" : is_open,
		&"is_locked" : is_locked
	})


func _on_opener_box_signal_emitted() -> void:
	if not has_pressures: return
	
	is_open = true

func _on_closer_box_signal_emitted() -> void:
	if not has_pressures: return
	if _player_near: return
	
	is_open = false


func _on_player_detector_body_entered(_body: Node3D) -> void:
	_player_near = true

func _on_player_detector_body_exited(_body: Node3D) -> void:
	_player_near = false
