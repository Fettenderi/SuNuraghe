extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

@onready var _returning_state: State = %ReturningState

var _is_active := false

var _navigation_agent_3d : NavigationAgent3D

var _seen_timer : Timer

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	user.emit_voice()
	
	_seen_timer = Utils.timer(15.0, _on_seen_ended, _seen_timer)
	if not _seen_timer.is_inside_tree():
		add_child(_seen_timer, true)
	_seen_timer.start()
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	_navigation_agent_3d.path_desired_distance = 2.0

	_returning_state.last_position = user.global_position
	
	if info.has(&"speed"):
		max_speed = info[&"speed"]
	
	user.max_speed = max_speed
	user.change_rate = change_rate

	user.is_manual_jumping = true

	if info.has(&"located"):
		_navigation_agent_3d.target_position = info[&"located"]


#func _physics_process(delta: float) -> void:
	#if not _is_active: return
	#
	#Utils.update_just_speed(user, change_rate, max_speed, delta)

func update(info : Dictionary = {}) -> void:
	if info.has(&"touched"):
		var _toucher : Player = info[&"touched"]
		
		_toucher.start_dying(user.get_eyes_reference())
		state_machine.change_state(&"KillState", {&"to_look": _toucher})
		return

	if info.has(&"end"):
		user.end_buffered = true

	if info.has(&"located"):
		_navigation_agent_3d.target_position = info[&"located"]
		_seen_timer.stop()
		_seen_timer.start()
		return

	if info.has(&"arrived"):
		state_machine.change_state(&"WanderingState", {&"next_state": &"ReturningState"})

func _physics_process(_delta: float) -> void:
	if not _is_active: return
	
	user.set_jump_delay(0.8)
	user.request_jump()


func end() -> void:
	_is_active = false
	user.is_manual_jumping = false
	_navigation_agent_3d.path_desired_distance = 1.0

func _on_seen_ended() -> void:
	if not _is_active: return
	
	state_machine.change_state(&"WanderingState", {&"next_state": &"ReturningState"})
