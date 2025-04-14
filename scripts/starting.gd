extends VideoStreamPlayer

@export_file("*.tscn") var level_scene
@export_file("*.tscn") var menu_scene

var cutscene_data : GStorage

func _ready() -> void:
	cutscene_data = GStorage.create(&"cutscenes")

	if cutscene_data.has_data():
		_to_scene(menu_scene)
		return
	
	finished.connect(_to_scene.bind(level_scene))

func _to_scene(scene):
	cutscene_data.set_value("played", true)
	cutscene_data.save_data()
	get_tree().call_deferred("change_scene_to_file", scene)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_to_scene(menu_scene)
