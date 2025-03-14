extends State

const MAX_ELAPSED = 10
const MAX_SWINGS = 2
const SWING_ANGLE = PI / 2

var _is_active := false
var _elapsed : float
var _starting_rotation : float

func start(_info : Dictionary = {}) -> void:
	_is_active = true
	_elapsed = 0.0
	_starting_rotation = user._mesh.rotation.y

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_elapsed += delta
	user._mesh.rotation.y = (SWING_ANGLE / 2) *sin(MAX_SWINGS * 2 * PI * _elapsed / MAX_ELAPSED) + _starting_rotation

	if _elapsed >= MAX_ELAPSED:
		state_machine.change_state("ReturningState")

func end() -> void:
	_is_active = false
	
