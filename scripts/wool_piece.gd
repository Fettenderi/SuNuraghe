extends Node3D

@export var emitter_resource : EmitterRes

@export var amount := 1

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = $Mesh

var _available := true

func _ready() -> void:
	if emitter_resource != null:
		_interactable_box.emitter_resource = emitter_resource
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _available: return
	
	_available = false
	_interactable_box.set_active(false)
	PlayerStats.wool_pieces += amount
	_mesh.visible = false

func _load_data(data : GStorage) -> void:
	_available = bool(data.get_value(Utils.nhash(self) + &"available"))
	_interactable_box.set_active(_available)
	_mesh.visible = _available

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"available", _available)
