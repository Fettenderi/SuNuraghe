extends Node3D

var loading_save := ""

func _ready() -> void:
	Gui.set_visible(true)
	Gui.level_reference = self
	LevelStats.level_ready(loading_save)
	Gui.end_transition()
