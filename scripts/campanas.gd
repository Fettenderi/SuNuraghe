class_name Campanas
extends Node3D

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var wants_stop := false

func stop():
	wants_stop = true

func _actually_stop():
	if not wants_stop: return
	wants_stop = false
	_animation_player.play("custom/stopping")
