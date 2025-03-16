extends Node3D

@export var emitter_resource : EmitterRes
@export var mesh : Node3D

@onready var _interactable_box: InteractableBox = %InteractableBox

var _is_active := true

func _ready() -> void:
	if emitter_resource == null:
		print("CAMPANA NON COLLEGATA " + name)
		return
	
	_interactable_box.emitter_resource = emitter_resource

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _is_active: return
	
	_is_active = false
	mesh.visible = true
