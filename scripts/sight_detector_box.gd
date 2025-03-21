class_name SightDetectorBox
extends Area3D

@export var emitter_resource : EmitterRes

var _state := false

signal signal_emitted(value)

func _ready() -> void:
	area_entered.connect(_interactable_entered)

func _interactable_entered(area: Area3D):
	if _state: return
	
	_state = true
	if emitter_resource != null:
		emitter_resource.send_signal(_state)
	signal_emitted.emit(_state)
