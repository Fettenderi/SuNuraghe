extends Node3D

@export var emitter_resource : EmitterRes

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = %Mesh

var _is_active := false

func _ready() -> void:
	if emitter_resource == null:
		print("LEVA NON CONFIGURATA " + name)
		return
	
	if _interactable_box != null:
		_interactable_box.emitter_resource = emitter_resource

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if _is_active: return
	
	_is_active = true
	_interactable_box.set_active(false)
	_mesh.visible = false
