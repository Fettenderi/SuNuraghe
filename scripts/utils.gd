class_name Utils
extends Node

static func timer(wait_time : float, callable : Callable, timer_obj : Timer = null, one_shot := true, autostart := false) -> Timer:
	if timer_obj == null:
		return _create_timer(wait_time, callable, one_shot, autostart)

	timer_obj = Timer.new()
	timer_obj.wait_time = wait_time
	
	if not timer_obj.timeout.is_connected(callable):
		timer_obj.timeout.connect(callable)
	
	return timer_obj

static func _create_timer(wait_time : float, callable : Callable, one_shot := true, autostart := false) -> Timer:
	var _timer := Timer.new()
	
	_timer.one_shot = one_shot
	_timer.autostart = autostart
	_timer.wait_time = wait_time
	_timer.timeout.connect(callable)
	
	return _timer

static func update_movement_variables(user : Player, state : State, delta : float) -> void:
	if abs(user.max_speed - state.max_speed) >= 0.01:
		user.max_speed = lerp(user.max_speed, state.max_speed, 1.0 - exp(-state.change_rate * delta))
	else:
		user.max_speed = state.max_speed
		user.head_bob_amplitude = state.head_bob_amplitude
		user.head_bob_frequency = state.head_bob_frequency
	
	@warning_ignore("narrowing_conversion")
	Gui.update_wool_display(user.max_speed * 100)

static func update_just_speed(user : CharacterBody3D, change_rate : float, target_speed : float, delta : float) -> void:
	if not user is Player and not user is Creature:
		print("update_just_speed CHIAMATO DA CHI NON DOVREBBE" + user.name)
		return

	if abs(user.max_speed - target_speed) >= 0.01:
		user.max_speed = lerp(user.max_speed, target_speed, 1.0 - exp(-change_rate * delta))
	else:
		user.max_speed = target_speed
