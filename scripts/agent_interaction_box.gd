class_name PressurePlateBox
extends Area3D

@export var active := false

@export var receiver_resource : ReceiverRes
@export var emitter_resource : EmitterRes

signal signal_emitted(value)

func _ready() -> void:
	if receiver_resource != null:
		receiver_resource.received.connect((func(): active = not active).unbind(1))
	body_entered.connect(_interactable_entered)

func _interactable_entered(_body: Node3D):
	if not active: return
	
	if emitter_resource != null:
		emitter_resource.send_signal()
	signal_emitted.emit(true)
