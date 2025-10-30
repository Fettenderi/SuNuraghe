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

static func _smooth_piecewise(x: float, m : float, q : float, x_break : float) -> float:
	if x <= 0.0:
		return 0.0

	if x >= x_break:
		return m * x + q

	var a := m * (1 - x_break + q) / 4.0
	var b := (m * x_break + q - 8.0 * a) / 4.0

	return a * x * x * x + b * x * x

static func setup_movement_variables(user : Player, state : State) -> void:
	user.max_speed = state.max_speed
	user.head_bob_frequency = _smooth_piecewise(state.max_speed, 2.857, -3.0, 2.0)
	user.footsteps_player.set_period(2.0 / user.max_speed)

static func update_movement_variables(user : Player, state : State, delta : float) -> void:
	if abs(user.max_speed - state.max_speed) >= 0.01:
		user.max_speed = lerp(user.max_speed, state.max_speed, 1.0 - exp(-state.change_rate * delta))
		user.footsteps_player.set_period(2.0 / user.max_speed)
		
		var previous_head_bob_frequency := user.head_bob_frequency
		user.head_bob_frequency = lerp(user.head_bob_frequency, _smooth_piecewise(state.max_speed, 2.857, -3.0, 2.0), 1.0 - exp(-state.change_rate * delta))
		user.head_bob_phase = (previous_head_bob_frequency - user.head_bob_frequency) * user._head_bob_tick + user.head_bob_phase

static func update_just_speed(user : CharacterBody3D, change_rate : float, target_speed : float, delta : float) -> void:
	if not user is Creature:
		print("update_just_speed CHIAMATO DA CHI NON DOVREBBE" + user.name)
		return

	if abs(user.speed - target_speed) >= 0.01:
		user.speed = lerp(user.speed, target_speed, 1.0 - exp(-change_rate * delta))
	else:
		user.speed = target_speed

static func update_just_max_speed(user : CharacterBody3D, change_rate : float, target_speed : float, delta : float) -> void:
	if not user is Player:
		print("update_just_max_speed CHIAMATO DA CHI NON DOVREBBE" + user.name)
		return

	if abs(user.max_speed - target_speed) >= 0.01:
		user.max_speed = lerp(user.max_speed, target_speed, 1.0 - exp(-change_rate * delta))
	else:
		user.max_speed = target_speed


static func string_to_vector2(string := "") -> Vector2:
	if not string: return Vector2.ZERO
	
	var new_string: String = string.erase(0, 1)
	new_string = new_string.erase(new_string.length() - 1, 1)
	
	var array: PackedStringArray = new_string.split(", ")

	return Vector2(float(array[0]), float(array[1]))

static func string_to_vector3(string := "") -> Vector3:
	if not string: return Vector3.ZERO
	
	var new_string: String = string.erase(0, 1)
	new_string = new_string.erase(new_string.length() - 1, 1)
	
	var array: PackedStringArray = new_string.split(", ")

	return Vector3(float(array[0]), float(array[1]), float(array[2]))

static func string_to_vector4(string := "") -> Vector4:
	if not string: return Vector4.ZERO
	
	var new_string: String = string.erase(0, 1)
	new_string = new_string.erase(new_string.length() - 1, 1)
	
	var array: PackedStringArray = new_string.split(", ")

	return Vector4(float(array[0]), float(array[1]), float(array[2]), float(array[3]))

static func string_to_string_array(string := "") -> Array[String]:
	if not string: return []
	
	var new_string: String = string.erase(0, 1)
	new_string = new_string.erase(new_string.length() - 1, 1)
	
	var array: PackedStringArray = new_string.split(", ")

	return array

static func nhash(node: Node) -> String:
	return node.name + str(hash(node.name + str(node.get_path())))

static func clremap(ivalue, imin, imax, fmin, fmax):
	return clamp(remap(ivalue, imin, imax, fmin, fmax), fmin, fmax)
