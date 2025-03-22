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
