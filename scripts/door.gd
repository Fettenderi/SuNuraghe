extends Node3D

@export var receiver_resource : ReceiverRes

@onready var _csg_box_3d: CSGBox3D = %CSGBox3D

func _ready() -> void:
	if receiver_resource == null: return
	
	receiver_resource.received.connect(_set_open)

func _set_open(value):
	_csg_box_3d.set_deferred("use_collision", not value)
	_csg_box_3d.set_deferred("visible", not value)
