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

@export var footsteps_period := 1.0

var _active := false
var _should_crawl := false

func start(_info : Dictionary = {}) -> void:
	_active = true
	
	user.footsteps_player.set_period(footsteps_period)
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

func _on_crawl_detector_box_area_exited(_area: Area3D) -> void:
	_should_crawl = false
