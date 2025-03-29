extends State

@export var change_rate := 1.0

@export var max_speed := 3.0
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 0.3

var _active := false

func start(_info : Dictionary = {}) -> void:
	_active = true

func _physics_process(delta: float) -> void:
	if not _active: return

	Utils.update_movement_variables(user, self, delta)

	user._usual_update(delta)
	
	if user.is_on_floor():
		user.sound_maker.set_enabled(false)

func _unhandled_input(_event : InputEvent) -> void:
	if not _active: return
	
	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState")
		return

	if (Input.is_action_just_pressed(user.KEY_BIND_JUMP) or user.jump_buffered) and user.is_on_floor():
		user.velocity.y = user.jump_velocity
		user.sound_maker.set_enabled(true)

	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		user.jump_buffered = true

	if not user.is_on_floor(): return
	
	if user.stamina > 0.0 and Input.is_action_pressed(user.KEY_BIND_SPRINT):
		state_machine.change_state("SprintState")
	elif Input.is_action_pressed(user.KEY_BIND_COVER):
		state_machine.change_state("CoverState")


func end() -> void:
	_active = false
