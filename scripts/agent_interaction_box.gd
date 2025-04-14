class_name PressurePlateBox
extends Area3D

@export var inibiting : PressurePlateBox

var is_active := true

signal signal_emitted()

func _ready() -> void:
	body_entered.connect(_interactable_entered)
	if inibiting != null:
		body_exited.connect(_interactable_exited)
		inibiting.is_active = false

func _interactable_entered(_body: Node3D):
	if not is_active: return
	
	signal_emitted.emit()
	if inibiting != null:
		inibiting.is_active = true

func _interactable_exited(_body: Node3D):
	inibiting.is_active = false
