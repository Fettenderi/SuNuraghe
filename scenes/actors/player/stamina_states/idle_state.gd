extends State

@export var max_stamina := 3.0

func start(info : Dictionary = {}) -> void:
	
	user.stamina = max_stamina
	
	if info.has("consuming") and info["consuming"]:
		state_machine.change_state("ConsumingState", {"stamina": max_stamina, "max_stamina": max_stamina})
	
	Gui.set_stamina_visible(false)

func update(info : Dictionary = {}) -> void:
	if info.has("consuming") and info["consuming"]:
		state_machine.change_state("ConsumingState", {"stamina": max_stamina, "max_stamina": max_stamina})

func end() -> void:
	pass
