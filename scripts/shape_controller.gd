class_name ShapeController
extends Node

@export var shapes : Array[CollisionShape3D]

var _active := true
var _current_shape := 0

func set_active_shape(shape_index : int) -> void:
	_current_shape = shape_index
	_update_shape()

func set_active(value : bool) -> void:
	_active = value
	_update_shape()

func _update_shape():
	for i in range(len(shapes)):
		shapes[i].set_deferred("disabled", i != _current_shape or not _active)

func get_active_shape_index() -> int:
	return _current_shape

func get_shapes_count() -> int:
	return len(shapes)
