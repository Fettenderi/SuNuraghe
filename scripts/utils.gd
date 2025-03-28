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

static func _update_movement_variables(player : Player, state : State, delta : float) -> void:
	if abs(player._max_speed - state.max_speed) >= 0.01:
		player._max_speed = lerp(player._max_speed, state.max_speed, 1.0 - exp(-state.change_rate * delta))
	else:
		player._max_speed = state.max_speed
		player._head_bob_amplitude = state.head_bob_amplitude
		player._head_bob_frequency = state.head_bob_frequency
	
	#Gui.update_wool_display(player._max_speed * 100)
