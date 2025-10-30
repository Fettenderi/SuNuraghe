extends State

@export var change_rate := 1.0

@export var max_speed := 5.0

var _active := false

func start(_info : Dictionary = {}) -> void:
	_active = true

	user.sound_maker.set_enabled(true)
	user.stamina_sm.update({"consuming": true})

func _physics_process(delta: float) -> void:
	if not _active: return
	
	Utils.update_movement_variables(user, self, delta)

	user._usual_update(delta)

func _unhandled_input(event : InputEvent) -> void:
	if not _active: return
	
	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState")
		return

	
	if (Input.is_action_just_pressed(user.KEY_BIND_JUMP) or user.jump_buffered) and user.is_on_floor():
		user.velocity.y = user.jump_velocity

	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		user.jump_buffered = true

		#if event.is_action_pressed(user.KEY_BIND_COVER):
			#_cover_buffer = true
		#elif event.is_action_released(user.KEY_BIND_SPRINT):
			#_end_sprint_buffer = true
		#return

	if event.is_action_released(user.KEY_BIND_SPRINT):
		state_machine.change_state("WalkState")
	elif Input.is_action_pressed(user.KEY_BIND_COVER) and user.is_on_floor():
		state_machine.change_state("CoverState")

func end() -> void:
	_active = false

	user.sound_maker.set_enabled(false)
	user.stamina_sm.update({"consuming": false})
