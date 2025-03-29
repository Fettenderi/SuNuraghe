extends State

@export_subgroup("Speed")
@export var max_speed := 20.0
@export var min_speed := 0.5
@export var speed_sensitivity := 0.05
@export_subgroup("TimeScale")
@export var max_time_scale := 2.0
@export var min_time_scale := 0.1
@export var time_scale_sensitivity := 0.05

@onready var _toggle_cooldown_timer : Timer

var _leaving_state : String
var _in_toggle_cooldown := false
var _active := false
var _speed : float
var _time_scale : float

func start(info : Dictionary = {}) -> void:
	_active = true
	_in_toggle_cooldown = true
	_toggle_cooldown_timer.start()

	_speed = user._max_speed
	user.shape_controller.set_active(false)

	_leaving_state = "WalkState"

	if info.has("leaving_state"):
		_leaving_state = info["leaving_state"]


func end() -> void:
	_active = false
	
	user.shape_controller.set_active(true)


func _ready() -> void:
	_toggle_cooldown_timer = Timer.new()
	_toggle_cooldown_timer.one_shot = true
	_toggle_cooldown_timer.autostart = false
	_toggle_cooldown_timer.wait_time = 0.2
	_toggle_cooldown_timer.timeout.connect(_toggle_cooldown_ended)
	
	add_child(_toggle_cooldown_timer, true)
	
	_time_scale = Engine.time_scale

func _physics_process(delta: float) -> void:
	if not _active: return
	
	_move_player(delta)
	_rotate_player(delta)
	

func _unhandled_input(event: InputEvent) -> void:
	if not _active: return
	if _in_toggle_cooldown: return
	
	if Input.is_action_just_released(user.KEY_BIND_NOCLIP):
		state_machine.change_state(_leaving_state)
	
	if Input.is_action_pressed(user.KEY_BIND_COVER):
		_handle_time_scale(event)
	else:
		_handle_speed(event)

	

func _handle_speed(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_speed = lerp(_speed, max_speed, speed_sensitivity)
		user._max_speed = _speed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_speed = lerp(_speed, min_speed, speed_sensitivity)
		user._max_speed = _speed

func _handle_time_scale(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_time_scale = lerp(_time_scale, max_time_scale, time_scale_sensitivity)
		Engine.time_scale = _time_scale
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_time_scale = lerp(_time_scale, min_time_scale, time_scale_sensitivity)
		Engine.time_scale = _time_scale
	@warning_ignore("narrowing_conversion")
	Gui.update_wool_display(Engine.time_scale * 100)

func _move_player(_delta : float) -> void:
	var _input_dir := Input.get_vector(user.KEY_BIND_LEFT, user.KEY_BIND_RIGHT, user.KEY_BIND_FORWARD, user.KEY_BIND_BACKWARD).normalized()
	var _direction : Vector3 = user.camera_3d.global_transform.basis * Vector3(_input_dir.x, 0.0, _input_dir.y)

	user._speed = user._max_speed

	user.velocity = _direction * user._speed # * delta
	
	user.move_and_slide()

func _rotate_player(delta : float) -> void:
	user.quaternion = user.quaternion.slerp(Quaternion(Vector3.UP, user._rotation_target_player), user.mouse_acceleration * delta)
	
	user._head.quaternion = user._head.quaternion.slerp(Quaternion(Vector3.LEFT, user._rotation_target_head), user.mouse_acceleration * delta)


func _toggle_cooldown_ended() -> void:
	_in_toggle_cooldown = false
