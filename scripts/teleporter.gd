extends Node3D

@export var player : Player

@export var receiver_resource : ReceiverRes

func _ready() -> void:
	receiver_resource.received.connect(_teleport.unbind(1))

func _teleport() -> void:
	player.position = global_position
