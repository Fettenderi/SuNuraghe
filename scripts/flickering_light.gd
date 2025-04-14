@tool
class_name FlickeringLight
extends OmniLight3D

@export var receiver_resource : ReceiverRes

@export var lerp_speed := 3.0
@export var actual_max_energy := 0.5:
	set(value):
		actual_max_energy = value
		actual_min_energy = max(actual_max_energy - 0.25,0.0)
		_update_preview()

var actual_min_energy := 0.2

var _target_light := actual_max_energy
var _flicker_cooldown_timer : Timer

var _is_active := true:
	set(value):
		_is_active = value
		
		if _is_active:
			_target_light = actual_max_energy
			_flicker()
		else:
			_target_light = 0.0
			_flicker_cooldown_timer.stop()

var saves_individually := true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_flicker_cooldown_timer = Timer.new()
	_flicker_cooldown_timer.one_shot = true
	_flicker_cooldown_timer.autostart = false
	_flicker_cooldown_timer.timeout.connect(_flicker)
	
	add_child(_flicker_cooldown_timer, true)
	_flicker()
	
	if receiver_resource != null:
		receiver_resource.received.connect(_on_received)
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _flicker() -> void:
	_flicker_cooldown_timer.start(max(randfn(0.9, 0.5), 0.0))
	_target_light = actual_min_energy if _target_light > (actual_max_energy + actual_min_energy) / 2 else actual_max_energy

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	light_energy = lerp(light_energy, _target_light, 1.0 - exp(-delta * lerp_speed))

func _update_preview():
	light_energy = actual_max_energy

func _on_received(value : Variant):
	if value is bool:
		_is_active = value
		return
	
	if value is Vector3:
		actual_max_energy = max(actual_max_energy - value.x, 0.0)
		actual_min_energy = max(actual_min_energy - value.y, 0.0)
		omni_range = max(omni_range - value.z, 0.0)

func _load_data(data : GStorage) -> void:
	if not saves_individually: return
	if not data.has_value(Utils.nhash(self) + &"parameters"): return
	
	var _parameters := Utils.string_to_vector3(data.get_value(Utils.nhash(self) + &"parameters"))
	
	actual_max_energy = _parameters.x
	actual_min_energy = _parameters.y
	omni_range = _parameters.z
	
	_is_active = bool(data.get_value(Utils.nhash(self) + &"is_active"))

func _save_data(data : GStorage) -> void:
	if not saves_individually: return
	
	data.set_value(Utils.nhash(self) + &"is_active", _is_active)
	data.set_value(Utils.nhash(self) + &"parameters", Vector3(actual_max_energy, actual_min_energy, omni_range))
