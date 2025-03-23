class_name SightDetectorBox
extends Area3D

@export var active := false

@export var receiver_resource : ReceiverRes
@export var emitter_resource : EmitterRes

var _state := false

signal signal_emitted(value)

func _ready() -> void:
	if receiver_resource != null:
		receiver_resource.received.connect((func(): active = not active).unbind(1))
	area_entered.connect(_interactable_entered)

func _interactable_entered(_area: Area3D):
	if not active: return
	if _state: return
	
	_state = true
	if emitter_resource != null:
		emitter_resource.send_signal(_state)
	signal_emitted.emit(_state)
