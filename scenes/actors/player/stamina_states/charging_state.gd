extends State

@export var charging_factor := 0.5

var _max_stamina : float = 0.0
var _stamina : float
var _is_active := false

func start(info : Dictionary = {}) -> void:
	_is_active = true
	
	user.stamina = _stamina
	
	if info.has("stamina"):
		_stamina = info["stamina"]
	
	if _max_stamina <= 0.0 and info.has("max_stamina"):
		_max_stamina = info["max_stamina"]
	
	Gui.update_stamina(_stamina / _max_stamina)


func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_stamina += delta * charging_factor
	user.stamina = _stamina
	Gui.update_stamina(_stamina / _max_stamina)

	if _stamina >= _max_stamina:
		state_machine.change_state("IdleState")

func update(info : Dictionary = {}) -> void:
	if info.has("consuming") and info["consuming"]:
		state_machine.change_state("ConsumingState", {"stamina": _stamina})

func end() -> void:
	_is_active = false
