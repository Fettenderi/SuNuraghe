extends Node3D

@export var emitter_resource : EmitterRes

@onready var _interactable_box: InteractableBox = %InteractableBox
@onready var _mesh: Node3D = %Lever
@onready var _sfx_emitter: FmodEventEmitter3D = %SFXEmitter

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
	
	_sfx_emitter.play()
	_interactable_box.set_active(false)
	var tween := create_tween()
	
	tween.tween_property(_mesh, "rotation", Vector3(deg_to_rad(-124.9), _mesh.rotation.y, _mesh.rotation.z), 2.50).set_trans(Tween.TRANS_ELASTIC)

func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self) + &"is_active"): return
	
	_is_active = bool(data.get_value(Utils.nhash(self) + &"is_active"))
	_interactable_box.set_active(not _is_active)
	_mesh.rotation.x = deg_to_rad(-124.9 if _is_active else -55.1)

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"is_active", _is_active)
