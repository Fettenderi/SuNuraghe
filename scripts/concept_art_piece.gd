extends Node3D

@export var emitter_resource : EmitterRes

@export_enum("Design", "Illustration", "Model", "Sound") var concept_art_piece : String 

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = $Mesh
@onready var _sfx_emitter: FmodEventEmitter3D = %SFXEmitter

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
	_sfx_emitter.play()
	PlayerStats.concept_art_pieces.append(concept_art_piece)
	_mesh.visible = false

func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self)): return

	if not data.get_value(Utils.nhash(self))[&"available"]:
		queue_free()
	

func _save_data(data : GStorage) -> void:
	if _available: return
	
	data.set_value(Utils.nhash(self), {
		&"available" : _available
	})
