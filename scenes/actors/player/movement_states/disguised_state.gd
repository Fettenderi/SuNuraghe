extends State

@export var change_rate := 1.0

@export var max_walk_speed := 3.0
@export var max_dance_speed := 3.0
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 0.3

@export_subgroup("Little Jump Configuration")
@export var little_jump_time := 1.5
@export var little_jump_speed := 4.0
@export var little_jump_factor := 1.0

@onready var _sfx_bells: FmodEventEmitter3D = %SFXBells

var _active := false

var _is_shifted := false

var _starting_head_pos : float
var _little_jumping := false
var _little_jump_elapsed := 0.0

func start(_info : Dictionary = {}) -> void:
	_active = true
	
	_starting_head_pos = user.head_start_pos.y
	user.head_bob_amplitude = head_bob_amplitude
	user.head_bob_frequency = head_bob_frequency
	user.sound_maker.set_enabled(true)

func _physics_process(delta: float) -> void:
	if not _active: return

	if _little_jumping: _handle_jumping(delta)
	else: _handle_walking(delta)
	
	user._usual_update(delta)

func _roof_function(value : float, center : float):
	return max(2.0 * (center - abs(value * 2.0 - center)), 0.0)

func _unhandled_input(_event : InputEvent) -> void:
	if not _active: return
	
	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState", {"leaving_state": "DisguisedState"})
	
	if Input.is_action_just_pressed(user.KEY_BIND_COVER):
		_is_shifted = true
		get_tree().call_group(&"ShiftDetector", "player_shifted", true)
	elif Input.is_action_just_released(user.KEY_BIND_COVER):
		_is_shifted = false
		get_tree().call_group(&"ShiftDetector", "player_shifted", false)

func _handle_jumping(delta : float) -> void:
	_little_jump_elapsed += delta
	Utils.update_just_max_speed(user, change_rate, 0.0, delta)
	user.head_start_pos.y = lerp(user.head_start_pos.y, _starting_head_pos + little_jump_factor * _roof_function(_little_jump_elapsed, little_jump_time), 1.0 - exp(-delta * little_jump_speed))
	if _little_jump_elapsed >= little_jump_time:
		_little_jumping = false

func _handle_walking(delta : float) -> void:
	user.head_start_pos.y = lerp(user.head_start_pos.y, _starting_head_pos, 1.0 - exp(-delta * little_jump_speed))
	
	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		_little_jump_elapsed = 0.0
		_little_jumping = true
		_sfx_bells.play()
		TimeKeeper.player_input()
		return
	
	Engine.time_scale = 2.0 if Input.is_action_pressed("fast_forward") else 1.0
	#Utils.update_just_max_speed(user, change_rate, max_walk_speed, delta)
	Utils.update_just_max_speed(user, change_rate, max_dance_speed if _is_shifted else max_walk_speed, delta)


func end() -> void:
	_active = false
	user.sound_maker.set_enabled(false)
