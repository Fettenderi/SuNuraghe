extends Node

@export var load_saves := false

var level_data : GStorage

signal loading(data : GStorage)
signal saving(data : GStorage)

func level_ready() -> void:
	level_data = GStorage.create(&"saves")
	
	if load_saves:
		_load_data()

func _load_data() -> void:
	loading.emit(level_data)

func save_data() -> void:
	saving.emit(level_data)
