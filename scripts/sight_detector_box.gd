class_name SightDetectorBox
extends Area3D

@export var active := false
@export var emit_watcher_position := false

@export var receiver_resource : ReceiverRes
@export var emitter_resource : EmitterRes

signal signal_emitted(value)

func _ready() -> void:
	if receiver_resource != null:
		receiver_resource.received.connect((func(): active = not active).unbind(1))
	area_entered.connect(_interactable_entered)
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)

func _interactable_entered(area: Area3D):
	if not active: return
	
	active = false   
	signal_emitted.emit(true)
	
	if emitter_resource == null: return
	
	if emit_watcher_position:
		var _player_pos : Vector3 = area.get_parent().get_parent().global_position
		emitter_resource.send_signal(_player_pos)
	else:
		emitter_resource.send_signal()

func _load_data(data : GStorage) -> void:
	active = bool(data.get_value(Utils.nhash(self) + &"is_active"))

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"is_active", active)
