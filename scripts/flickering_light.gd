@tool
extends OmniLight3D

@export var lerp_speed := 3.0
@export var actual_max_energy := 1.0:
	set(value):
		actual_max_energy = value
		_update_preview()
@export var actual_min_energy := 0.2

var _target_light := actual_max_energy
var _flicker_cooldown_timer : Timer

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_flicker_cooldown_timer = Timer.new()
	_flicker_cooldown_timer.one_shot = true
	_flicker_cooldown_timer.autostart = false
	_flicker_cooldown_timer.timeout.connect(_flicker)
	
	add_child(_flicker_cooldown_timer, true)
	_flicker()
	

func _flicker() -> void:
	_flicker_cooldown_timer.start(max(randfn(0.9, 0.5), 0.0))
	_target_light = actual_min_energy if _target_light > (actual_max_energy + actual_min_energy) / 2 else actual_max_energy

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	light_energy = lerp(light_energy, _target_light, 1.0 - exp(-delta * lerp_speed))

func _update_preview():
	light_energy = actual_max_energy
