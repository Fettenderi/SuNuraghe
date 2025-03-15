class_name InteractableBox
extends Area3D

@export var emitter_resource : EmitterRes

@export var required_input : StringName
@export_multiline var gui_text : String

var _is_active := false
var _is_interactable := false

func _ready() -> void:
	area_entered.connect(_interactable_entered)
	area_exited.connect(_interactable_exited)

func _interactable_entered(area: Area3D):
	if area.is_in_group(&"Interaction"):
		_is_interactable = true
		Gui.append_interaction(gui_text)

func _interactable_exited(area: Area3D):
	if area.is_in_group(&"Interaction"):
		_is_interactable = false
		Gui.remove_interaction(gui_text)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_interactable: return
	
	if event.is_action_pressed(required_input, false, true):
		_is_active = not _is_active
		emitter_resource.send_signal(_is_active)
