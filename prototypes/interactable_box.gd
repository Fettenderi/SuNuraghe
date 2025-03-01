class_name InteractableBox
extends Area3D

@export var required_input : String
@export var gui_text : String

var _is_active := false

signal activated

func _ready() -> void:
	area_entered.connect(_interactable_entered)
	area_exited.connect(_interactable_exited)

func _interactable_entered(area: Area3D):
	if area.is_in_group(&"Interaction"):
		_is_active = true
		print("GUI Updated: " + gui_text)

func _interactable_exited(area: Area3D):
	if area.is_in_group(&"Interaction"):
		_is_active = false
		print("GUI Updated: ")

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active: return
	
	if event.is_action_pressed(required_input):
		activated.emit()
