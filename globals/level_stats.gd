extends Node

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

func level_ready() -> void:
	sig_level_ready.emit()
	
	level_data = GStorage.create(&"saves")
	config_data = GStorage.create(&"config")
	
	if load_saves and level_data.has_data():
		loading.emit(level_data)

	if load_saves and config_data.has_data():
		config_loading.emit(config_data)

	sig_saves_ready.emit()

func save_data() -> void:
	if not save_saves: return
	
	saving.emit(level_data)
	
	level_data.save_data()

func save_configs() -> void:
	if not save_saves: return
	
	config_saving.emit(config_data)
	
	config_data.save_data()
