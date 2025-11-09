extends State

@export var change_rate := 1.0

@export_subgroup("Wandering")
@export var wander_time := 10
@export var swings := 2
@export var swing_angle := PI / 2

var _is_active := false
var _elapsed : float
var _starting_rotation : float

var _next_state : String
var _next_info : Dictionary = {}

func start(info : Dictionary = {}) -> void:
	_is_active = true
	_elapsed = 0.0
	_starting_rotation = user.mesh.rotation.y
	
	user.max_speed = 0.0
	user.change_rate = change_rate
	
	if info.has(&"next_state"):
		_next_state = info[&"next_state"]
	
	if info.has(&"next_info"):
		_next_info = info[&"next_info"]
	else:
		_next_info = {}

func update(info : Dictionary = {}) -> void:
	if info.has(&"touched"):
		var _toucher : Player = info[&"touched"]
		
		_toucher.start_dying(user.get_eyes_reference())
		state_machine.change_state(&"KillState", {&"to_look": _toucher})
		return

	if info.has(&"end"):
		user.end_buffered = true
	
	if info.has(&"located"):
		state_machine.change_state(&"ChaseState", {&"located": info[&"located"]})

func end() -> void:
	_is_active = false

	user.mesh.rotation.y = _starting_rotation

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_elapsed += delta
	user.mesh.rotation.y = (swing_angle / 2) * sin(swings * 2 * PI * _elapsed / wander_time) + _starting_rotation

	#Utils.update_just_speed(user, change_rate, 0.0, delta)
	
	if _elapsed >= wander_time:
		state_machine.change_state(_next_state, _next_info)

func get_save_data() -> Dictionary:
	return {
		&"next_state" : _next_state,
		&"next_info" : _next_info
	}
