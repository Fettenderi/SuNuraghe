extends State

@export var max_speed := 1.0
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 0.3

var _active := false

func start(_info : Dictionary = {}) -> void:
	_active = true
	
	user._head_start_pos.y -= 0.6
	user._max_speed = max_speed
	user._head_bob_amplitude = head_bob_amplitude
	user._head_bob_frequency = head_bob_frequency

func _input(event : InputEvent) -> void:
	if not _active: return

	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		user._jump_buffered = true

	if event.is_action_pressed(user.KEY_BIND_SPRINT):
		state_machine.change_state("SprintState")
	elif event.is_action_pressed(user.KEY_BIND_COVER):
		state_machine.change_state("CoverState")
	elif event.is_action_released(user.KEY_BIND_COVER):
		state_machine.change_state("WalkState")

func end() -> void:
	_active = false
	
	user._head_start_pos.y += 0.6
