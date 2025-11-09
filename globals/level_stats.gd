extends Node

@export_file("*.tscn") var level_scene

@export var save_saves := false
@export var load_saves := false

var level_data : GStorage
var config_data : GStorage

signal sig_level_ready
signal sig_saves_ready
signal loading(data : GStorage)
signal saving(data : GStorage)

signal config_loading(data : GStorage)
signal config_saving(data : GStorage)

func level_ready(save : String = "") -> void:
	sig_level_ready.emit()
	
	if save  == "":
		level_data = GStorage.create(&"saves")
	else:
		level_data = GStorage.create(&"saves_" + str(save))
	config_data = GStorage.create(&"config")
	
	if load_saves and level_data.has_data():
		loading.emit(level_data)

	if load_saves and config_data.has_data():
		config_loading.emit(config_data)

	sig_saves_ready.emit()

func load_data(save_name : String = "") -> void:
	if not load_saves: return
	
	var level : Node3D = Gui.level_reference
	
	level.queue_free()
	level = load(level_scene).instantiate()
	
	level.loading_save = save_name
	
	get_tree().root.add_child(level)

func save_data(save_name : String = "") -> void:
	if not save_saves: return
	
	if save_name == "":
		saving.emit(level_data)
		level_data.call_deferred(&"save_data")
	else:
		var new_level_data := GStorage.create(&"saves_" + save_name)
		saving.emit(new_level_data)
		new_level_data.call_deferred(&"save_data")

func save_configs() -> void:
	if not save_saves: return
	
	config_saving.emit(config_data)
	
	config_data.save_data()
