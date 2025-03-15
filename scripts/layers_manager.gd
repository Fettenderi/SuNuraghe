@tool
extends Node

@export_subgroup("Settings")
@export var layer0_enabled := true:
	set(value):
		layer0_enabled = value
		_update_layer_visibility(layer0, value)
@export var layer1_enabled := true:
	set(value):
		layer1_enabled = value
		_update_layer_visibility(layer1, value)
@export var layer2_enabled := true:
	set(value):
		layer2_enabled = value
		_update_layer_visibility(layer2, value)
@export var layer3_enabled := true:
	set(value):
		layer3_enabled = value
		_update_layer_visibility(layer3, value)

@export_subgroup("Configuration")
@export var layer0 : Array[Node3D]
@export var layer1 : Array[Node3D]
@export var layer2 : Array[Node3D]
@export var layer3 : Array[Node3D]

func _ready() -> void:
	_update_layer_visibility(layer0, layer0_enabled)
	_update_layer_visibility(layer1, layer1_enabled)
	_update_layer_visibility(layer2, layer2_enabled)
	_update_layer_visibility(layer3, layer3_enabled)

func _update_layer_visibility(layer : Array[Node3D], visibility : bool):
	if layer == null: return
	
	for _element in layer:
		_element.visible = visibility
