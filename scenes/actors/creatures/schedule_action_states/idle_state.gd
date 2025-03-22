extends State

var _receiver : ReceiverRes
var _is_active := false

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if info.has("await"):
		_receiver = user.get_schedule_receiver(info["await"])
		_receiver.received.connect(_on_received_signal)

func _on_received_signal(_value) -> void:
	if not _is_active: return
	
	user.progress()
	_receiver.received.disconnect(_on_received_signal)

func end() -> void:
	_is_active = false
