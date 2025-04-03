extends Control

@export_file("*.tscn") var level_scene

@onready var _continue_button: Button = %ContinueButton

func _ready() -> void:
	LevelStats.level_ready()
	
	_continue_button.set_visible(LevelStats.level_data.has_data())

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file(level_scene)

func _on_continue_button_pressed() -> void:
	LevelStats.load_saves = true
	get_tree().change_scene_to_file(level_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
