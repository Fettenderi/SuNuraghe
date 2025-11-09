extends Node

@export var player : Player
@export var receiver : ReceiverRes

func _ready() -> void:
	if receiver != null:
		receiver.received.connect(player.shake)
