extends Node3D

@export var emitter_resource : EmitterRes

@onready var mesh: Node3D = %Mesh

@export var wool_required := 6

var _is_active := true

func _ready() -> void:
	if emitter_resource == null:
		print("CAMPANA NON COLLEGATA " + name)
		return

	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _is_active: return
	if PlayerStats.wool_pieces < wool_required: return
	
	_is_active = false
	mesh.visible = true
	PlayerStats.wool_pieces -= wool_required
	
	if emitter_resource != null:
		emitter_resource.send_signal(true)

func _load_data(data : GStorage) -> void:
	_is_active = data.get_value(Utils.nhash(self) + &"is_active")
	mesh.visible = not _is_active

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"is_active", _is_active)
