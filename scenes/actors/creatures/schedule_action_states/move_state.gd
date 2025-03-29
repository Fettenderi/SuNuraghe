extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

var _is_active := false

var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
	
	if info.has("position"):
		var _target : Marker3D = user.get_node(info["position"])
		
		if _target == null:
			print(user.name + " NON HA UN NODEPATH ASSOLUTO")
			return
		_navigation_agent_3d.target_position = _target.global_position
	
	if info.has("speed"):
		max_speed = info["speed"]

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		print("OH SCUS TI SONO VENUTO ADDOSSO " + user.name + " " + name)
		return

	if info.has("arrived"):
		user.progress()

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)

func end() -> void:
	_is_active = false
