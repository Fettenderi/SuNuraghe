extends Node

@export var player : Player
@export var receiver : ReceiverRes

func _ready() -> void:
	if receiver != null:
		receiver.received.connect(_shake.unbind(1))

func _shake():
	player.shake()
