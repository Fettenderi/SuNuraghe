extends State

@export var speed := 300.0

var _patroling_resource : PatrolingResource

func start(info : Dictionary = {}) -> void:
	user.speed = speed
	
	if user.end_buffered:
		state_machine.stop()
		user.queue_free()
	
	if info.has("arrived"):
		_patroling_resource.waypoint_reached()

	if _patroling_resource == null:
		_patroling_resource = user.patroling_resource

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
