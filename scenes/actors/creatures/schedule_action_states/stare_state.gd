extends State

@export var change_rate := 1.0

var _is_active := false

var _receiver : ReceiverRes
var _stare_timer : Timer

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if info.has("await"):
		_receiver = info["await"]
		_receiver.received.connect(_on_received_signal)
		return
	
	if info.has("time"):
		_stare_timer = Utils.timer(info["time"], _on_stare_timer_ended, _stare_timer)
		
		if not _stare_timer.is_inside_tree():
			add_child(_stare_timer, true)
		
		_stare_timer.start()

func end() -> void:
	_is_active = false


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, 0.0, delta)

	user.look(user.target.global_position, delta)

func _on_stare_timer_ended() -> void:
	if not _is_active: return
	
	_stare_timer.stop()
	user.progress()

func _on_received_signal(_value) -> void:
	if not _is_active: return
	
	user.progress()
