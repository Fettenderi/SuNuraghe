extends State

@export var fatigue_time := 0.4

var _is_active := false
var _fatigue_elapsed := 0.0

func start(_info : Dictionary = {}) -> void:
	_is_active = true
	
	_fatigue_elapsed = 0.0
	user.stamina = 0.0
	
	Gui.update_stamina(_fatigue_elapsed / fatigue_time)

	user.movement_sm.change_state("WalkState")

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_fatigue_elapsed += delta
	Gui.update_stamina(_fatigue_elapsed / fatigue_time)
	
	if _fatigue_elapsed >= fatigue_time:
		state_machine.change_state("IdleState")

func end() -> void:
	_is_active = false
