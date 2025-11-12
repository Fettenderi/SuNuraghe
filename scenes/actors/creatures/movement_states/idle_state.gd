extends State

@export var change_rate := 1.0

var _receiver : ReceiverRes
var _is_active := false

var _vigilant := false
var _expected_rotation := 0.0
var _has_expected_rotation := false

func start(info : Dictionary = {}) -> void:
	if user.end_buffered:
		state_machine.stop()
		return
	
	_is_active = true
	
	user.max_speed = 0.0
	user.change_rate = change_rate
	
	if info.has(&"await"):
		_receiver = info[&"await"]
		if not _receiver.received.is_connected(_on_received_signal):
			_receiver.received.connect(_on_received_signal)
	else:
		_receiver = null
	
	if info.has(&"vigilant"):
		_vigilant = info[&"vigilant"]

	if info.has(&"rotation"):
		_expected_rotation = info[&"rotation"]
		_has_expected_rotation = true
	else:
		_has_expected_rotation = false

func update(info : Dictionary = {}) -> void:
	if info.has(&"touched"):
		var _toucher : Player = info[&"touched"]
		
		_toucher.start_dying(user.get_eyes_reference())
		state_machine.change_state(&"KillState", {&"to_look": _toucher})
		return

	if _vigilant and info.has(&"located"):
		user.interrupted_state = name

		state_machine.change_state(&"ChaseState", {&"located": info[&"located"]})
		return
	
	if info.has(&"end"):
		state_machine.stop()


func end() -> void:
	_vigilant = false
	_is_active = false


func _on_received_signal(_value) -> void:
	if not _is_active: return
	
	_receiver.received.disconnect(_on_received_signal)

	user.progress()

func _physics_process(delta: float) -> void:
	if not _is_active: return
		
	if not _has_expected_rotation: return
	user.global_rotation.y = lerp_angle(user.global_rotation.y, _expected_rotation, 1.0 - exp(-user.TURNING_SPEED * delta))
