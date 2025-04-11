extends Node3D

@export var emitter_resource : EmitterRes

@export_enum("Design", "Illustration", "Model", "Sound") var concept_art_piece : String 

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = $Mesh

var _available := true

func _ready() -> void:
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _available: return
	
	_available = false
	_interactable_box.set_active(false)
	if emitter_resource != null:
		emitter_resource.send_signal()
	PlayerStats.concept_art_pieces.append(concept_art_piece)
	_mesh.visible = false

func _load_data(data : GStorage) -> void:
	_available = bool(data.get_value(Utils.nhash(self) + &"available"))
	_interactable_box.set_active(_available)
	_mesh.visible = _available

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"available", _available)
