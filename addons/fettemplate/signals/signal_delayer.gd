extends Timer

@export var receiver : ReceiverRes
@export var emitter : EmitterRes

func _ready() -> void:
	receiver.received.connect(_received_signal)

func _received_signal(value):
	start()
	for _connection in timeout.get_connections():
		timeout.disconnect(_connection["callable"])
	timeout.connect(_send_signal.bind(value))

func _send_signal(value):
	emitter.send_signal(value)
