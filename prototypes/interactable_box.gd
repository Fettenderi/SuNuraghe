class_name InteractableBox
extends Area3D

@export var required_input : StringName
@export var gui_text : String

var _is_active := false

signal activated

func _ready() -> void:
	area_entered.connect(_interactable_entered)
	area_exited.connect(_interactable_exited)

func _interactable_entered(area: Area3D):
	if area.is_in_group(&"Interaction"):
		_is_active = true
		Gui.append_interaction(gui_text)

func _interactable_exited(area: Area3D):
	if area.is_in_group(&"Interaction"):
		_is_active = false
		Gui.remove_interaction(gui_text)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active: return
	
	if event.is_action_pressed(required_input, false, true):
		activated.emit()
