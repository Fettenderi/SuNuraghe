extends Node3D

@export var emitter_resource : EmitterRes

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = %Lever

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
	_mesh.rotation.x = deg_to_rad(-124.9)

func _load_data(data : GStorage) -> void:
	_is_active = bool(data.get_value(Utils.nhash(self) + &"is_active"))
	_interactable_box.set_active(not _is_active)
	_mesh.rotation.x = deg_to_rad(-124.9 if _is_active else -55.1)

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"is_active", _is_active)
