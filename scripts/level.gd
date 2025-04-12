extends Node3D

func _ready() -> void:
	Gui.set_visible(true)
	LevelStats.level_ready()
	
	#Engine.time_scale = 2.0
