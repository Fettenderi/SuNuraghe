extends State

@export var speed := 300.0

var _patroling_resource : PatrolingResource

func start(info : Dictionary = {}) -> void:
	user.speed = speed
	
	if info.has("arrived"):
		_patroling_resource.waypoint_reached()

	if _patroling_resource == null:
		print(user.patroling_resource)
		_patroling_resource = user.patroling_resource

func update(info : Dictionary = {}) -> void:
	if info.has("arrived"):
		_patroling_resource.waypoint_reached()
	
	if _patroling_resource.has_targets():
		user.navigation_agent_3d.target_position = _patroling_resource.get_current_target()
	

func end() -> void:
	%ReturningState.last_position = user.position
