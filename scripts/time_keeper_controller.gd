extends Node

@export var receiver_resource : ReceiverRes

func _ready() -> void:
	receiver_resource.received.connect(_on_received.unbind(1))

func _on_received():
	TimeKeeper.start_dance_mode()
