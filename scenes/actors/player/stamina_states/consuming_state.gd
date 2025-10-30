extends State

@export var changing_factor := 1.0

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
	
	Gui.set_stamina_visible(true)
	Gui.update_stamina(_stamina / _max_stamina)

func _physics_process(delta: float) -> void:
	if not _is_active: return
	
	_stamina -= delta * changing_factor
	user.stamina = _stamina
	Gui.update_stamina(_stamina / _max_stamina)
	
	if _stamina <= 0.0:
		state_machine.change_state("FatiguedState")

func update(info : Dictionary = {}) -> void:
	if info.has("consuming") and not info["consuming"]:
		state_machine.change_state("ChargingState", {"stamina": _stamina, "max_stamina": _max_stamina})

func end() -> void:
	_is_active = false
