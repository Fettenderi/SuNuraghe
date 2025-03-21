extends Node3D

@export var emitter_resource : EmitterRes

@export var amount := 1

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = %Mesh

var _available := true

func _ready() -> void:
	if emitter_resource != null:
		_interactable_box.emitter_resource = emitter_resource

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _available: return
	
	_available = false
	_interactable_box.set_active(false)
	PlayerStats.wool_pieces += amount
	_mesh.visible = false
