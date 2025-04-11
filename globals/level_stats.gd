extends Node

@export var save_saves := false
@export var load_saves := false

var level_data : GStorage

signal loading(data : GStorage)
signal saving(data : GStorage)

func level_ready() -> void:
	level_data = GStorage.create(&"saves")
	
	if not load_saves or not level_data.has_data(): return
	
	loading.emit(level_data)

func save_data() -> void:
	if not save_saves: return
	
	saving.emit(level_data)
	
	level_data.save_data()
