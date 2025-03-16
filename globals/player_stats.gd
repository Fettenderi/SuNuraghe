extends Node

@export var wool_pieces := 0:
	set(value):
		wool_pieces = value
		Gui.update_wool_display(value)
