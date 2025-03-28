extends State

@export var speed := 300.0

var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	user.speed = speed

	if info.has("position"):
		var _target : Marker3D = info["position"]
		_navigation_agent_3d.target_position = _target.global_position
	
	if info.has("speed"):
		user.speed = info["speed"]

func update(info : Dictionary = {}) -> void:
	if info.has("arrived"):
		user.progress()
