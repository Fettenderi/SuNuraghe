@tool
extends Node3D

const ARRIVED_THRESHOLD = 0.01

@export var debug := false

@export var is_open := false:
	set(value):
		is_open = value
		_set_open(value)

@export var receiver_resource : ReceiverRes

@onready var _mesh: Node3D = %Mesh
@onready var _interactable_box: InteractableBox = %InteractableBox

var _target_rotation := 0.0
var _arrived := true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_set_open(is_open)
	if receiver_resource == null:
		_interactable_box.is_active = is_open
	else:
		receiver_resource.received.connect(_set_open)

func _set_open(value : bool):
	if Engine.is_editor_hint():
		if _mesh != null:
			_mesh.rotation.y = 0.0 if value else PI / 2
	else:
		_arrived = false
		_target_rotation = 0.0 if value else PI / 2

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _arrived: return
	
	_mesh.rotation.y = lerp_angle(_mesh.rotation.y, _target_rotation, 1 - exp(-2.0 * delta))
	
	if abs(_mesh.rotation.y - _target_rotation) <= ARRIVED_THRESHOLD:
		_arrived = true

func _on_interactable_box_signal_emitted(value: Variant) -> void:
	is_open = value
