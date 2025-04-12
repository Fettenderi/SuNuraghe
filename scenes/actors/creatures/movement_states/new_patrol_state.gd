extends State

@export var change_rate := 1.0

@export var max_speed := 300.0

var _is_active := false

var _vigilant := false

var _navigation_agent_3d : NavigationAgent3D
var _waypoints : Array[Marker3D]
var _waypoint_progress := 0

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	if user.end_buffered:
		state_machine.stop()
		user.queue_free()

	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d
		
	if info.has("waypoint_progress"):
		_waypoint_progress = info["waypoint_progress"]
		_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
	
	if info.has("vigilant"):
		_vigilant = info["vigilant"]
	
	if info.has("waypoints"):
		var _container : Node = user.get_node(info["waypoints"])
		
		if _container == null:
			print(user.name + " NON HA UN NODEPATH ASSOLUTO")
		else:
			_waypoint_progress = 0
			_waypoints.clear()
			
			for _child : Node3D in _container.get_children():
				if _child is Marker3D:
					_waypoints.append(_child)
			
			_navigation_agent_3d.target_position = _waypoints[_waypoint_progress].global_position
	
	if info.has("speed"):
		max_speed = info["speed"]


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	Utils.update_just_speed(user, change_rate, max_speed, delta)

func update(info : Dictionary = {}) -> void:
	if info.has("touched"):
		var _toucher : Player = info["touched"]
		
		_toucher.start_dying(user.get_eyes_reference())
		state_machine.change_state("KillState", {"to_look": _toucher})
		return

	if info.has("end"):
		state_machine.stop()
		user.queue_free()

	if _vigilant and info.has("located"):
		state_machine.change_state("ChaseState", {"located": info["located"]})
		return

	if info.has("arrived"):
		_waypoint_progress += 1
		
		if _waypoint_progress >= len(_waypoints):
			user.progress()
			return
		
		state_machine.change_state("WanderingState", {"next_state": "PatrolState", "next_info": {"waypoint_progress": _waypoint_progress}})

func end() -> void:
	_is_active = false
