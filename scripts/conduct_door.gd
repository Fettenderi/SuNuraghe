@tool
extends Node3D

@export var is_open := false:
	set(value):
		is_open = value
		_set_open(value)

@export var receiver_resource : ReceiverRes

@onready var _mesh: Node3D = %Mesh

func _ready() -> void:
	_set_open(is_open)
	
	if Engine.is_editor_hint(): return
	
	if receiver_resource != null:
		receiver_resource.received.connect(_toggle_open.unbind(1))

func _toggle_open():
	is_open = not is_open

func _set_open(value):
	if _mesh != null:
		_mesh.visible = not value
		for _child in _mesh.get_children():
			if _child is CSGShape3D:
				_child.use_collision = not value
