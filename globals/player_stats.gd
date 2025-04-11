extends Node

@export var wool_pieces := 0:
	set(value):
		wool_pieces = value
		Gui.update_wool_display(value)

var disguised := false:
	set(value):
		disguised = value
		disguised_changed.emit(value)

var concept_art_pieces : Array = []

signal disguised_changed(value : bool)
