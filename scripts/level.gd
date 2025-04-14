extends Node3D

func _ready() -> void:
	Gui.set_visible(true)
	Gui.level_reference = self
	LevelStats.level_ready()
	Gui.end_transition()
