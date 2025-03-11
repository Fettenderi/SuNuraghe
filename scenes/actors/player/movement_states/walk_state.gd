extends State

@export var max_speed := 3.0
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 0.3

var _active := false

func start(_info : Dictionary = {}) -> void:
	_active = true
	
	user._max_speed = max_speed
	user._head_bob_amplitude = head_bob_amplitude
	user._head_bob_frequency = head_bob_frequency


func _physics_process(delta: float) -> void:
	if not _active: return
	
	user._usual_update(delta)
	
	if user.is_on_floor():
		user._sound_maker.set_enabled(false)

func _unhandled_input(event : InputEvent) -> void:
	if not _active: return
	
	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState")
	
	if (Input.is_action_just_pressed(user.KEY_BIND_JUMP) or user._jump_buffered) and user.is_on_floor():
		user.velocity.y = user.jump_velocity
		user._sound_maker.set_enabled(true)

	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		user._jump_buffered = true

	if not user.is_on_floor(): return
	
	if event.is_action_pressed(user.KEY_BIND_SPRINT):
		state_machine.change_state("SprintState")
	elif event.is_action_pressed(user.KEY_BIND_COVER):
		state_machine.change_state("CoverState")


func end() -> void:
	_active = false
