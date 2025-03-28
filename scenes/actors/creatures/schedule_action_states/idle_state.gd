extends State

var _receiver : ReceiverRes
var _is_active := false

var _vigilant := false

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if info.has("await"):
		_receiver = info["await"]
		_receiver.received.connect(_on_received_signal)
	
	if info.has("vigilant"):
		_vigilant = info["vigilant"]

func update(info : Dictionary = {}) -> void:
	if _vigilant and info.has("located"):
		state_machine.change_state("ChaseState", {"located": info["located"]})
		return
	
	if info.has("end"):
		state_machine.stop()
		user.queue_free()


func end() -> void:
	_vigilant = false
	_is_active = false


func _on_received_signal(_value) -> void:
	if not _is_active: return
	
	user.progress()
