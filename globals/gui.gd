extends CanvasLayer

@onready var _interaction_text : RichTextLabel = %InteractionText
@onready var _stamina_bar: ProgressBar = %StaminaBar
@onready var _wool_pieces_display: Label = %WoolPiecesDisplay

var _interaction_array : Array[String]

func _ready() -> void:
	_wool_pieces_display.text = str(PlayerStats.wool_pieces)

func update_wool_display(value: int) -> void:
	if _wool_pieces_display == null: return
	
	_wool_pieces_display.text = str(value)

func append_interaction(text : String) -> void:
	_interaction_array.append("[center]" + text)
	_interaction_text.text += "[center]" + text

func remove_interaction(text : String) -> void:
	_interaction_array.erase("[center]" + text)
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

func update_stamina(value: float):
	_stamina_bar.value = value

func set_stamina_visible(value: bool):
	_stamina_bar.visible = value
