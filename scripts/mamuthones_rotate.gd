@tool
extends Node3D

var _elapsed := 0.0

func _physics_process(delta: float) -> void:
	rotation.y = _elapsed * 0.5
	
	_elapsed += delta
