extends CanvasLayer

@onready var _interaction_text : RichTextLabel = %InteractionText

var _interaction_array : Array[String]

func append_interaction(text : String) -> void:
	_interaction_array.append("[center]" + text)
	_interaction_text.text += "[center]" + text + "[br]"

func remove_interaction(text : String) -> void:
	_interaction_array.erase("[dcenter]" + text)
	_interaction_text.text = ""
