extends CanvasLayer

@onready var _interaction_text : RichTextLabel = %InteractionText
@onready var _stamina_bar: ProgressBar = %StaminaBar
@onready var _wool_pieces_display: Label = %WoolPiecesDisplay
@onready var _kidnap_screen: ColorRect = %KidnapScreen

var _interaction_array : Array[String]

var _wool_tween : Tween

func _ready() -> void:
	_wool_pieces_display.text = str(PlayerStats.wool_pieces)

func update_wool_display(value: int) -> void:
	if _wool_pieces_display == null: return
	
	_wool_pieces_display.text = str(value)
	
	_wool_tween = create_tween()
	_wool_tween.set_parallel(false)
	
	_wool_tween.tween_property(_wool_pieces_display, "modulate", Color("#ffffff"), 1)
	_wool_tween.tween_property(_wool_pieces_display, "modulate", Color("#ffffff00"), 1).set_delay(4)

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

func start_kidnap_screen():
	var tween := create_tween()
	
	tween.tween_property(_kidnap_screen, "modulate", Color("#ffffff"), 3)
	
	await get_tree().create_timer(7).timeout
	
	get_tree().quit()
