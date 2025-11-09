@tool
extends Node3D

@export var bake_override := false:
	set(value):
		bake_override = value
		_set_bake_mode(value)

@export var emitter_resource : EmitterRes

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = %Mesh
@onready var _sfx_emitter: FmodEventEmitter3D = %SFXEmitter

var _available := true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

func _set_bake_mode(value : bool) -> void:
	_mesh.position.y = -1.0 if value else 0.0

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _available: return
	
	_available = false
	_interactable_box.set_active(false)
	_mesh.visible = false
	_sfx_emitter.play()
	PlayerStats.disguised = true
	
	if emitter_resource != null:
		emitter_resource.send_signal()


func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self)): return

	if not data.get_value(Utils.nhash(self))[&"available"]:
		queue_free()

func _save_data(data : GStorage) -> void:
	if _available: return
	
	data.set_value(Utils.nhash(self), {
		&"available" : _available
	})
