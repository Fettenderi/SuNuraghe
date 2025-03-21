class_name InteractableBox
extends Area3D

@export var emitter_resource : EmitterRes

@export var required_input : StringName
@export_multiline var gui_text : String

@export var is_active := true
@export var state := false
var _in_range := false

signal signal_emitted(value)

func _ready() -> void:
	area_entered.connect(_interactable_entered)
	area_exited.connect(_interactable_exited)

func _interactable_entered(area: Area3D):
	if not is_active: return
	
	if area.is_in_group(&"Interaction"):
		_in_range = true
		Gui.append_interaction(gui_text)

func _interactable_exited(area: Area3D):
	if not is_active: return
	
	if area.is_in_group(&"Interaction"):
		_in_range = false
		Gui.remove_interaction(gui_text)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return
	if not _in_range: return
	
	if event.is_action_pressed(required_input, false, true):
		state = not state
		if emitter_resource != null:
			emitter_resource.send_signal(state)
		signal_emitted.emit(state)

func set_active(active : bool) -> void:
	is_active = active
	
	if _in_range:
		_in_range = false
		Gui.remove_interaction(gui_text)
