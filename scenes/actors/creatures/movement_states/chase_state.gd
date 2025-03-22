extends State

@export var speed := 300.0

var _is_active := false
var _target_visible := true

var _navigation_agent_3d : NavigationAgent3D

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	user.speed = speed
	
	if _navigation_agent_3d == null:
		_navigation_agent_3d = user.navigation_agent_3d

	_target_visible = true
	
	if info.has("located"):
		_navigation_agent_3d.target_position = info["located"]

func update(info : Dictionary = {}) -> void:
	if info.has("end"):
		user.end_buffered = true

	if info.has("located"):
		_navigation_agent_3d.target_position = info["located"]
		return

	if info.has("arrived") and not _target_visible:
		state_machine.change_state("WanderingState", {"next_state": "ReturningState"})

func end() -> void:
	_is_active = false

func _on_eyes_not_visible() -> void:
	if not _is_active: return
	
	_target_visible = false

func _on_eyes_located(_collider: Player) -> void:
	if not _is_active: return
	
	_target_visible = true
