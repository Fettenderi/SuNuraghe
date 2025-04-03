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
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if _is_active: return
	
	_is_active = true
	_interactable_box.set_active(false)
	_mesh.visible = false

func _load_data(data : GStorage) -> void:
	_is_active = bool(data.get_value(Utils.nhash(self) + &"is_active"))
	_interactable_box.set_active(not _is_active)
	_mesh.visible = not _is_active

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"is_active", _is_active)
