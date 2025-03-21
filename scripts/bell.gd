extends Node3D

@export var emitter_resource : EmitterRes
@export var mesh : Node3D

@export var wool_required := 6

var _is_active := true

func _ready() -> void:
	if emitter_resource == null:
		print("CAMPANA NON COLLEGATA " + name)
		return

func _on_interactable_box_signal_emitted(_value: Variant) -> void:
	if not _is_active: return
	if PlayerStats.wool_pieces < wool_required: return
	
	_update_mesh()
	
	_is_active = false
	emitter_resource.send_signal(true)
	PlayerStats.wool_pieces -= wool_required

func _update_mesh():
	mesh.visible = true
