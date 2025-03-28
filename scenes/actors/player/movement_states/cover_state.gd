extends State

enum {
	STANDING,
	CROUCHING,
	CRAWLING
}

@export var change_rate := 1.0

@export var max_speed := 1.0
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 0.3

var _active := false
var _wants_crawl := false

func start(_info : Dictionary = {}) -> void:
	_active = true

	user._head_start_pos.y -= 0.6
	user.shape_controller.set_active_shape(CROUCHING)

	if _wants_crawl:
		state_machine.change_state("CrawlState")


func _physics_process(delta: float) -> void:
	if not _active: return
	
	Utils._update_movement_variables(user, self, delta)

	user._usual_update(delta)
	
	if _wants_crawl:
		state_machine.change_state("CrawlState")

func _unhandled_input(event : InputEvent) -> void:
	if not _active: return
	
	if Input.is_action_just_pressed(user.KEY_BIND_NOCLIP):
		state_machine.change_state("NoclipState")
		return

	if Input.is_action_just_pressed(user.KEY_BIND_JUMP):
		user._jump_buffered = true

	if user.stamina > 0.0 and Input.is_action_pressed(user.KEY_BIND_SPRINT):
		state_machine.change_state("SprintState")
	elif Input.is_action_pressed(user.KEY_BIND_COVER):
		state_machine.change_state("CoverState")
	elif event.is_action_released(user.KEY_BIND_COVER):
		state_machine.change_state("WalkState")

func end() -> void:
	_active = false
	
	user._head_start_pos.y += 0.6
	user.shape_controller.set_active_shape(STANDING)

func _on_crawl_detector_box_area_entered(_area: Area3D) -> void:
	_wants_crawl = true

func _on_crawl_detector_box_area_exited(_area: Area3D) -> void:
	_wants_crawl = false
