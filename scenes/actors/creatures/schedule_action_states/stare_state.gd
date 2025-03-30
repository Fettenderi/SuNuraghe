extends State

@export var change_rate := 1.0

var _is_active := false

var _receiver : ReceiverRes
var _stare_timer : Timer
var _next_state : String
var _next_info : Dictionary = {}

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if info.has("await"):
		_receiver = info["await"]
		_receiver.received.connect(_on_received_signal)
		return
	
	_next_state = ""
	
	if info.has("next_state"):
		_next_state = info["next_state"]
	
	if info.has("next_info"):
		_next_info = info["next_info"]

	
	if info.has("time"):
		_stare_timer = Utils.timer(info["time"], _on_stare_timer_ended, _stare_timer)
		
		if not _stare_timer.is_inside_tree():
			add_child(_stare_timer, true)
		
		_stare_timer.start()

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		var _toucher : Player = info["touched"]
		
		_toucher.start_dying(user.get_eyes_location())
		state_machine.change_state("KillState", {"to_look": _toucher.global_position})


func end() -> void:
	_is_active = false


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, 0.0, delta)

	user.look(user.target.global_position, delta)

func _on_stare_timer_ended() -> void:
	if not _is_active: return
	
	_stare_timer.stop()
	
	if _next_state.is_empty():
		user.progress()
	else:
		state_machine.change_state(_next_state, _next_info)

func _on_received_signal(_value) -> void:
	if not _is_active: return
	
	if _next_state != "":
		user.progress()
	else:
		state_machine.change_state(_next_state, _next_info)
