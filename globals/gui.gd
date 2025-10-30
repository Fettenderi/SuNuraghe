extends CanvasLayer

enum InputMethod {
	KEYBOARD,
	SWITCH,
	PS4,
	PS5,
	XBOX,
	STEAMDECK
}

@onready var _interaction_text : RichTextLabel = %InteractionText
@onready var _requirement_text: RichTextLabel = %RequirementText
@onready var _stamina_bar: ProgressBar = %StaminaBar
@onready var _wool_pieces_display: Label = %WoolPiecesDisplay
@onready var _transition_screen: ColorRect = %TransitionScreen
@onready var _pausa: ColorRect = %Pausa
@onready var _language_cycle_button: Button = %LanguageCycleButton
@onready var _master_volume_selector: VBoxContainer = %MasterVolumeSelector
@onready var _quit_button: Button = %QuitButton
@onready var _fullscreen_button: Button = %FullscreenButton
@onready var _reset_demo_button: Button = %ResetDemoButton

var _interaction_array : Array[String]
var _requirement_array : Array[String]

var _wool_tween : Tween

var level_reference : Node3D

var _input_method := InputMethod.KEYBOARD:
	set(value):
		if _input_method == value: return
		
		_input_method = value
		
		_can_change_window_mode = _input_method != InputMethod.STEAMDECK
		
		if not _can_change_window_mode:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			_fullscreen_button.text = tr("Schermo Intero - Nativo")

var _can_change_window_mode := true

func _ready() -> void:
	_wool_pieces_display.text = str(PlayerStats.wool_pieces)
	LevelStats.config_saving.connect(_on_saving)
	LevelStats.config_loading.connect(_on_loading)

func update_wool_display(value: int) -> void:
	if _wool_pieces_display == null: return
	
	_wool_pieces_display.text = str(value)
	
	_wool_tween = create_tween()
	_wool_tween.set_parallel(false)
	
	_wool_tween.tween_property(_wool_pieces_display, "modulate", Color("#ffffff"), 1)
	_wool_tween.tween_property(_wool_pieces_display, "modulate", Color("#ffffff00"), 1).set_delay(4)

func append_interaction(text : String) -> void:
	_interaction_array.append(text)
	_interaction_text.text += text

func remove_interaction(text : String) -> void:
	_interaction_array.erase(text)
	_interaction_text.text = ""


func append_requirements(text : String) -> void:
	_requirement_array.append(text)
	_requirement_text.text += text

func remove_requirements(text : String) -> void:
	_requirement_array.erase(text)
	_requirement_text.text = ""


func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		match Input.get_joy_name(event.device):
			"PS4 Controller":
				_input_method = InputMethod.PS4
			"PS5 Controller":
				_input_method = InputMethod.PS5
			"Xbox Controller":
				_input_method = InputMethod.XBOX
			"Nintendo Switch Controller":
				_input_method = InputMethod.SWITCH
			"Steam Deck":
				_input_method = InputMethod.STEAMDECK
				
	elif event is InputEventKey or event is InputEventMouseButton:
		_input_method = InputMethod.KEYBOARD


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if level_reference == null: return
		var tween := create_tween()
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			level_reference.process_mode = Node.PROCESS_MODE_ALWAYS
			tween.tween_property(_pausa, "modulate", Color("#ffffff00"), 1.5).from(Color("#ffffff"))
			_language_cycle_button.set_deferred("disabled", true)
			_quit_button.set_deferred("disabled", true)
			_fullscreen_button.set_deferred("disabled", true)
			_reset_demo_button.set_deferred("disabled", true)
			_master_volume_selector.set_enabled(false)
			LevelStats.save_configs()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			level_reference.process_mode = Node.PROCESS_MODE_DISABLED
			tween.tween_property(_pausa, "modulate", Color("#ffffff"), 1.5).from(Color("#ffffff00"))
			_language_cycle_button.set_deferred("disabled", false)
			_quit_button.set_deferred("disabled", false)
			_reset_demo_button.set_deferred("disabled", false)
			if _can_change_window_mode:
				_fullscreen_button.set_deferred("disabled", false)
			_language_cycle_button.grab_focus()
			_master_volume_selector.set_enabled(true)

func update_stamina(value: float):
	_stamina_bar.value = value

func set_stamina_visible(value: bool):
	_stamina_bar.visible = value

func start_kidnap_screen():
	var tween := create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff"), 0.05).from(Color("#ffffff00")).set_delay(0.45)
	
	await get_tree().create_timer(1).timeout
	
	tween = create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff00"), 1.5).from(Color("#ffffff")).set_delay(0.5)
	
	LevelStats.config_data.set_value(&"game_finished", true)
	LevelStats.config_data.save_data()
	
	get_tree().call_deferred("change_scene_to_file", "res://scenes/credits.tscn")

func start_transition():
	var tween := create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff"), 0.5).from(Color("#ffffff00")).set_delay(0.5)
	
	await get_tree().create_timer(1).timeout
	
	get_tree().call_deferred("reload_current_scene")

func end_transition():
	var tween := create_tween()
	
	tween.tween_property(_transition_screen, "modulate", Color("#ffffff00"), 1.5).from(Color("#ffffff"))

func _on_language_cycle_button_button_up() -> void:
	match TranslationServer.get_locale():
		"it_IT":
			TranslationServer.set_locale("en_EN")
		"en_EN":
			TranslationServer.set_locale("it_IT")

func _on_fullscreen_button_button_up() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_fullscreen_button.text = tr("Schermo Intero - ON") if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else tr("Schermo Intero - OFF")

func _on_quit_button_button_up() -> void:
	LevelStats.save_configs()
	
	get_tree().quit()

func _on_reset_demo_button_button_up() -> void:
	LevelStats.level_data.clear()
	LevelStats.config_data.set_value(&"game_finished", false)
	LevelStats.config_data.set_value(&"cutscene_played", false)
	LevelStats.config_data.save_data()


func _on_saving(data : GStorage) -> void:
	data.set_value(&"language", TranslationServer.get_locale())
	data.set_value(&"window_mode", "FULLSCREEN" if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else "MAXIMIZED")

func _on_loading(data : GStorage) -> void:
	if data.has_value(&"language"):
		TranslationServer.set_locale(data.get_value(&"language"))
	
	if data.has_value(&"window_mode"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if data.get_value(&"window_mode") == "FULLSCREEN" else DisplayServer.WINDOW_MODE_MAXIMIZED)
		_fullscreen_button.text = tr("Schermo Intero - ON") if data.get_value(&"window_mode") == "FULLSCREEN" else tr("Schermo Intero - OFF")
