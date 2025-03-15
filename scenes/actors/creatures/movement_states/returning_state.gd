extends State

@export var speed := 300.0

var last_position : Vector3

func start(_info : Dictionary = {}) -> void:
	user.speed = speed

	user.navigation_agent_3d.target_position = last_position

func update(info : Dictionary = {}) -> void:
	if info.has("arrived"):
		state_machine.change_state("PatrolState")
