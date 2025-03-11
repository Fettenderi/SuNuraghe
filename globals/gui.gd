extends CanvasLayer

@onready var _interaction_text : RichTextLabel = %InteractionText

var _interaction_array : Array[String]

func append_interaction(text : String) -> void:
	_interaction_array.append("[center]" + text)
	_interaction_text.text += "[center]" + text + "[br]"

func remove_interaction(text : String) -> void:
	_interaction_array.erase("[dcenter]" + text)
	_interaction_text.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if Engine.is_embedded_in_editor():
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().quit()
