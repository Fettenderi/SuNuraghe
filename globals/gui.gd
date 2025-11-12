extends CanvasLayer

const PAUSE_MENU_ANIMATION = 0.5

const DEFAULT_DANCE_HINT_SIZE = 80

enum InputMethod {
	KEYBOARD,
	SWITCH,
	PS4,
	PS5,
	XBOX,
	STEAMDECK
}

const INPUT_HINTS = {
	"interact" : {
		InputMethod.KEYBOARD : "res://assets/ui/Key_E.png[/img]",
		InputMethod.SWITCH : "res://assets/ui/Switch_Y.png[/img]",
		InputMethod.PS4 : "]res://assets/ui/PS4_Square.png[/img]",
		InputMethod.PS5 : "res://assets/ui/PS5_Square.png[/img]",
		InputMethod.XBOX : "res://assets/ui/XboxSeriesX_X.png[/img]",
		InputMethod.STEAMDECK : "res://assets/ui/SteamDeck_X.png[/img]"
	},
	"dance" : {
		InputMethod.KEYBOARD : "res://assets/ui/Space_Key.png[/img]",
		InputMethod.SWITCH : "res://assets/ui/Switch_B.png[/img]",
		InputMethod.PS4 : "res://assets/ui/PS4_Cross.png[/img]",
		InputMethod.PS5 : "res://assets/ui/PS5_Cross.png[/img]",
		InputMethod.XBOX : "res://assets/ui/XboxSeriesX_A.png[/img]",
		InputMethod.STEAMDECK : "res://assets/ui/SteamDeck_A.png[/img]"
	}
}

@export_file("*.tscn") var level_scene

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
@onready var _timing_hint: RichTextLabel = %TimingHint

@warning_ignore("unused_private_class_variable")
@onready var _debug_label: Label = %DebugLabel

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

var _reset_sureness := 0

var _quicksave_index := 0

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

func append_interaction(text : String, input : StringName) -> void:
	var _actual_text := _get_interaction_text(text, input)
	
	_interaction_array.append(_actual_text)
	_interaction_text.text += _actual_text

func remove_interaction(text : String, input : StringName) -> void:
	var _actual_text := _get_interaction_text(text, input)
	
	_interaction_array.erase(_actual_text)
	_interaction_text.text = ""

func set_timing_hint_visibility(value: bool):
	_timing_hint.set_deferred(&"visible", value)
	
	var tween := create_tween()
	if value:
		tween.tween_property(_timing_hint, "modulate", Color("#ffffff"),0.7).from(Color("#ffffff00"))
		change_timing_hint_size()
	else:
		tween.tween_property(_timing_hint, "modulate", Color("#ffffff00"),0.7).from(Color("#ffffff"))

func change_timing_hint_size(size := DEFAULT_DANCE_HINT_SIZE):
	_timing_hint.text = &"[center]" + _get_input_text(&"dance", size)

func highlight_timing_hint():
	var tween := create_tween()
	
	tween.tween_method(change_timing_hint_size, DEFAULT_DANCE_HINT_SIZE, DEFAULT_DANCE_HINT_SIZE + 20, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_method(change_timing_hint_size, DEFAULT_DANCE_HINT_SIZE + 20, DEFAULT_DANCE_HINT_SIZE, 0.2).set_ease(Tween.EASE_IN)

func made_timing_mistake():
	var tween := create_tween()
	
	tween.tween_property(_timing_hint, "position", _timing_hint.position + Vector2(-10, 0.0), 0.05).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_timing_hint, "position", _timing_hint.position + Vector2(10, 0.0), 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_timing_hint, "position", _timing_hint.position, 0.05).set_trans(Tween.TRANS_ELASTIC)

func _get_interaction_text(text : String, input : StringName) -> String:
	return &"[center]" + _get_input_text(input) + " " + tr(text)

func _get_input_text(input : StringName, size := 40) -> String:
	return "[img={0}]".format([size]) + INPUT_HINTS[input][_input_method]



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
			"Steam Virtual Gamepad":
				_input_method = InputMethod.STEAMDECK
				
	elif event is InputEventKey or event is InputEventMouseButton:
		_input_method = InputMethod.KEYBOARD


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if level_reference == null: return
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			_hide_pause_menu()
		else:
			_show_pause_menu()

	if event.is_action_pressed("ui_cancel"):
		if level_reference == null: return
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			_hide_pause_menu()

	if event.is_action_pressed("quicksave"):
		LevelStats.save_data(str(_quicksave_index))
		
		_quicksave_index = (_quicksave_index + 1) % 8
		
		LevelStats.config_data.set_value(&"quicksave_index", _quicksave_index)
		LevelStats.config_data.save_data()


	if event.is_action_pressed("quickload"):
		LevelStats.load_data(str((_quicksave_index - 1) % 8))

	if event.is_action_pressed("quickload0"):
		LevelStats.load_data()

	if event.is_action_pressed("quickload1"):
		LevelStats.load_data("0")

	if event.is_action_pressed("quickload2"):
		LevelStats.load_data("1")

	if event.is_action_pressed("quickload3"):
		LevelStats.load_data("2")

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
		_:
			TranslationServer.set_locale("en_EN")

func _on_fullscreen_button_button_up() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_fullscreen_button.text = tr("Schermo Intero - ON") if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else tr("Schermo Intero - OFF")

func _on_quit_button_button_up() -> void:
	LevelStats.save_configs()
	
	get_tree().quit()

func _on_reset_demo_button_button_up() -> void:
	if _reset_sureness > 2:
		LevelStats.level_data.clear()
		LevelStats.config_data.set_value(&"game_finished", false)
		LevelStats.config_data.set_value(&"cutscene_played", false)
		LevelStats.config_data.save_data()
		
		LevelStats.load_data()
		#get_tree().quit()
		return

	_reset_demo_button.text = tr("SEI SICURO?")
	
	for _i in range(_reset_sureness):
		_reset_demo_button.text = _reset_demo_button.text + "?"
	
	_reset_sureness += 1
	
	_reset_demo_button.add_theme_font_size_override("font_size", 20 + 4 * _reset_sureness)

func _on_reset_demo_button_focus_exited() -> void:
	_reset_sureness = 0
	
	_reset_demo_button.remove_theme_font_size_override("font_size")
	
	_reset_demo_button.text = tr("Reset Demo")


func _on_saving(data : GStorage) -> void:
	data.set_value(&"language", TranslationServer.get_locale())
	data.set_value(&"window_mode", "FULLSCREEN" if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else "MAXIMIZED")

func _on_loading(data : GStorage) -> void:
	if data.has_value(&"window_mode"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if data.get_value(&"window_mode") == "FULLSCREEN" else DisplayServer.WINDOW_MODE_MAXIMIZED)
		_fullscreen_button.text = tr("Schermo Intero - ON") if data.get_value(&"window_mode") == "FULLSCREEN" else tr("Schermo Intero - OFF")
	if data.has_value(&"quicksave_index"):
		_quicksave_index = data.get_value(&"quicksave_index")

func _show_pause_menu():
	var _tween := create_tween()

	level_reference.process_mode = Node.PROCESS_MODE_DISABLED
	_tween.tween_property(_pausa, "modulate", Color("#ffffff"), PAUSE_MENU_ANIMATION)
	_language_cycle_button.set_deferred("disabled", false)
	_quit_button.set_deferred("disabled", false)
	_reset_demo_button.set_deferred("disabled", false)
	if _can_change_window_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_fullscreen_button.set_deferred("disabled", false)
	_language_cycle_button.grab_focus()
	_master_volume_selector.set_enabled(true)

func _hide_pause_menu():
	var _tween := create_tween()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	level_reference.process_mode = Node.PROCESS_MODE_ALWAYS
	_tween.tween_property(_pausa, "modulate", Color("#ffffff00"), PAUSE_MENU_ANIMATION)
	_language_cycle_button.set_deferred("disabled", true)
	_quit_button.set_deferred("disabled", true)
	_fullscreen_button.set_deferred("disabled", true)
	_reset_demo_button.set_deferred("disabled", true)
	_master_volume_selector.set_enabled(false)
	LevelStats.save_configs()
