extends VideoStreamPlayer

@export_file("*.tscn") var level_scene

var level_data : GStorage
var config_data : GStorage

func _ready() -> void:
	level_data = GStorage.create(&"saves")
	config_data = GStorage.create(&"config")

	if config_data.has_value(&"cutscene_played") and config_data.get_value(&"cutscene_played"):
		if config_data.has_value(&"game_finished") and config_data.get_value(&"game_finished"):
			config_data.set_value(&"game_finished", false)
			config_data.save_data()
			level_data.clear()
		else:
			_to_scene(level_scene)
		return
	
	finished.connect(_to_scene.bind(level_scene))

func _to_scene(scene):
	config_data.set_value(&"cutscene_played", true)
	config_data.set_value(&"game_finished", false)
	config_data.save_data()
	
	get_tree().call_deferred("change_scene_to_file", scene)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_to_scene(level_scene)
