extends State

enum {
	STANDING,
	CROUCHING,
	CRAWLING
}

@export var change_rate := 1.0

@export var max_speed := 1.0

@export var craw_detector : Area3D

var _active := false
var _should_crawl := false

var _standup_delay_timer : Timer
var _on_standup_cooldown := false

func start(_info : Dictionary = {}) -> void:
	_active = true
	
	_standup_delay_timer = Utils.timer(0.1, _on_standup_delay_ended)
	if not _standup_delay_timer.is_inside_tree():
		add_child(_standup_delay_timer, true)
	
	user.head_start_pos.y -= 0.9
	user.shape_controller.set_active_shape(CRAWLING)

func _physics_process(delta: float) -> void:
	if not _active: return
	
	Utils.update_movement_variables(user, self, delta)

	user._usual_update(delta)
	if not _should_crawl:
		state_machine.change_state("WalkState")

func _unhandled_input(_event : InputEvent) -> void:
	if not _active: return

	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState")

func end() -> void:
	_active = false
	
	user.head_start_pos.y += 0.9
	user.shape_controller.set_active_shape(STANDING)

func _on_crawl_detector_box_area_entered(_area: Area3D) -> void:
	_should_crawl = true
	
	_on_standup_cooldown = false
	
	if not _active: return
	_standup_delay_timer.stop()

func _on_crawl_detector_box_area_exited(_area: Area3D) -> void:
	if not _active: return
	
	_on_standup_cooldown = true
	_standup_delay_timer.start()

func _on_standup_delay_ended():
	_on_standup_cooldown = false
	
	if not _active: return
	
	if not craw_detector.has_overlapping_areas():
		_should_crawl = false
