extends State

@export var max_speed := 5.0
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 0.3

var _active := false

#var _cover_buffer := false
#var _end_sprint_buffer := false

func start(_info : Dictionary = {}) -> void:
	_active = true
	#_cover_buffer = false
	#_end_sprint_buffer = false

	user._sound_maker.set_enabled(true)
	user._max_speed = max_speed
	user._head_bob_amplitude = head_bob_amplitude
	user._head_bob_frequency = head_bob_frequency

func _physics_process(delta: float) -> void:
	if not _active: return
	
	user._usual_update(delta)
	
	#if not user.is_on_floor():
		#if Input.is_action_just_pressed(user.KEY_BIND_COVER):
			#_cover_buffer = true
		#elif Input.is_action_just_released(user.KEY_BIND_SPRINT):
			#_end_sprint_buffer = true
		#return


func _unhandled_input(event : InputEvent) -> void:
	if not _active: return
	
	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState")

	
	if (Input.is_action_just_pressed(user.KEY_BIND_JUMP) or user._jump_buffered) and user.is_on_floor():
		user.velocity.y = user.jump_velocity

	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		user._jump_buffered = true

	if not user.is_on_floor(): return
		#if event.is_action_pressed(user.KEY_BIND_COVER):
			#_cover_buffer = true
		#elif event.is_action_released(user.KEY_BIND_SPRINT):
			#_end_sprint_buffer = true
		#return

	if Input.is_action_pressed(user.KEY_BIND_COVER):
		state_machine.change_state("CoverState")
	elif event.is_action_released(user.KEY_BIND_SPRINT):
		state_machine.change_state("WalkState")

func end() -> void:
	_active = false

	user._sound_maker.set_enabled(false)
