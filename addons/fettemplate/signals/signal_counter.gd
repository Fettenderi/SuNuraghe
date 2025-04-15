extends Node

@export var receiver_resource : ReceiverRes
@export var emitter_resource : EmitterRes

@export var signals_count : int = 1

var _counted := 0

func _ready() -> void:
	receiver_resource.received.connect(_on_received.unbind(1))

func _on_received():
	_counted += 1
	
	if _counted >= signals_count:
		_counted = 0
		emitter_resource.send_signal()
