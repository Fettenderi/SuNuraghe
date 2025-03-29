extends State

@export var change_rate := 1.0

var _receiver : ReceiverRes
var _is_active := false

var _vigilant := false

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if info.has("await"):
		_receiver = info["await"]
		if not _receiver.received.is_connected(_on_received_signal):
			_receiver.received.connect(_on_received_signal)
	
	if info.has("vigilant"):
		_vigilant = info["vigilant"]

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		var _toucher : Player = info["touched"]
		
		_toucher.start_dying(user.get_eyes_location())
		state_machine.change_state("KillState", {"to_look": _toucher.global_position})
		return

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

func _physics_process(delta: float) -> void:
	if not _is_active: return
		
	Utils.update_just_speed(user, change_rate, 0.0, delta)
