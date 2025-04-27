extends FmodEventEmitter3D

@export var receiver_resource : ReceiverRes

func _ready() -> void:
	receiver_resource.received.connect(play)
