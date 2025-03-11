@tool
class_name ExpandedHitBox
extends Area3D

@export var shape : Shape3D:
	set(value):
		shape = value
		_update_shape()
@export var enabled := true:
	set(value):
		enabled = value
		set_enabled(enabled)

@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D

func _ready() -> void:
	_update_shape()

func _update_shape():
	if _collision_shape_3d == null: return
	
	_collision_shape_3d.shape = shape
	_collision_shape_3d.set_deferred("disabled", not enabled)

func set_enabled(value: bool):
	if _collision_shape_3d == null: return
	
	_collision_shape_3d.set_deferred("disabled", not value)
