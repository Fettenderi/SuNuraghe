extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

var _patroling_resource : PatrolingResource

var _is_active := false

func start(info : Dictionary = {}) -> void:
	_is_active = true
	if user.end_buffered:
		state_machine.stop()
		user.queue_free()
	
	if info.has("arrived"):
		_patroling_resource.waypoint_reached()

	if _patroling_resource == null:
		_patroling_resource = user.patroling_resource

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		state_machine.stop()
		user.queue_free()

	if info.has("located"):
		state_machine.change_state("ChaseState", {"located": info["located"]})
		return

	if info.has("arrived"):
		_patroling_resource.waypoint_reached()
		state_machine.change_state("WanderingState", {"next_state": "PatrolState"})
		return
	
	if _patroling_resource.has_targets():
		user.navigation_agent_3d.target_position = _patroling_resource.get_current_target()

func end() -> void:
	_is_active = false
