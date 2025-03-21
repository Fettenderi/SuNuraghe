extends State

@export var speed := 300.0

@export_subgroup("Wandering")
@export var wander_time := 10
@export var swings := 2
@export var swing_angle := PI / 2

var _is_active := false
var _elapsed : float
var _starting_rotation : float

var _next_state : String

func start(info : Dictionary = {}) -> void:
	user.speed = speed
	
	_is_active = true
	_elapsed = 0.0
	_starting_rotation = user._mesh.rotation.y
	
	if info.has("next_state"):
		_next_state = info["next_state"]

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		user.end_buffered = true

func end() -> void:
	_is_active = false


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_elapsed += delta
	user._mesh.rotation.y = (swing_angle / 2) * sin(swings * 2 * PI * _elapsed / wander_time) + _starting_rotation

	if _elapsed >= wander_time:
		state_machine.change_state(_next_state)
