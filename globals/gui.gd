extends CanvasLayer

@onready var _interaction_text : RichTextLabel = %InteractionText
@onready var _requirement_text: RichTextLabel = %RequirementText
@onready var _stamina_bar: ProgressBar = %StaminaBar
@onready var _wool_pieces_display: Label = %WoolPiecesDisplay
@onready var _transition_screen: ColorRect = %TransitionScreen
@onready var _pausa: ColorRect = %Pausa

var _interaction_array : Array[String]
var _requirement_array : Array[String]

var _wool_tween : Tween

var level_reference : Node3D

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


func append_requirements(text : String) -> void:
	_requirement_array.append("[center]" + text)
	_requirement_text.text += "[center]" + text

func remove_requirements(text : String) -> void:
	_requirement_array.erase("[center]" + text)
	_requirement_text.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var tween := create_tween()
		
		if level_reference == null: return
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			level_reference.process_mode = Node.PROCESS_MODE_ALWAYS
			tween.tween_property(_pausa, "modulate", Color("#ffffff00"), 1.5).from(Color("#ffffff"))
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			level_reference.process_mode = Node.PROCESS_MODE_DISABLED
			tween.tween_property(_pausa, "modulate", Color("#ffffff"), 1.5).from(Color("#ffffff00"))

func update_stamina(value: float):
	_stamina_bar.value = value

func set_stamina_visible(value: bool):
	_stamina_bar.visible = value

func start_kidnap_screen():
	var tween := create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff"), 0.5).from(Color("#ffffff00")).set_delay(0.5)
	
	await get_tree().create_timer(1).timeout
	
	tween = create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff00"), 1.5).from(Color("#ffffff")).set_delay(0.5)
	
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func start_transition():
	var tween := create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff"), 0.5).from(Color("#ffffff00")).set_delay(0.5)
	
	await get_tree().create_timer(1).timeout
	
	get_tree().reload_current_scene()

func end_transition():
	var tween := create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff00"), 1.5).from(Color("#ffffff"))
