@tool
extends Node3D

@export var amount := 1:
	set(value):
		amount = value
		_update_tooltip()

@export var distance := 1.0:
	set(value):
		distance = value
		_update_tooltip()

@export var receiver_resource : ReceiverRes:
	set(value):
		receiver_resource = value
		_update_parameters()

@export var omni_range := 3.0:
	set(value):
		omni_range = value
		_update_parameters()

@export var lerp_speed := 3.0:
	set(value):
		lerp_speed = value
		_update_parameters()

@export var actual_max_energy := 1.0:
	set(value):
		actual_max_energy = value
		actual_min_energy = max(actual_max_energy - 0.25,0.0)
		_update_parameters()

var actual_min_energy := 0.2

var _lights : Array[FlickeringLight] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_tooltip()
		return
	
	LevelStats.saving.connect(_save_data)
	LevelStats.loading.connect(_load_data)


func _update_tooltip() -> void:
	_clear_tooltip()
	
	if amount <= 0:
		return
	
	if amount == 1:
		_create_light(global_position)
		return
	
	var _angle : float
	
	for i in range(amount):
		_angle = i * TAU / amount
		_create_light(distance * Vector3(cos(_angle), 0.0, sin(_angle)))

func _update_parameters() -> void:
	for _light in _lights:
		_light.omni_range = omni_range
		_light.receiver_resource = receiver_resource
		_light.lerp_speed = lerp_speed
		_light.actual_max_energy = actual_max_energy
		_light.actual_min_energy = actual_min_energy
		_light.saves_individually = false

func _clear_tooltip() -> void:
	for _light in _lights:
		_light.queue_free()
	_lights.clear()

func _create_light(pos : Vector3) -> void:
	var _light : FlickeringLight
	
	_light = FlickeringLight.new()
	_light.omni_range = omni_range
	_light.receiver_resource = receiver_resource
	_light.lerp_speed = lerp_speed
	_light.actual_max_energy = actual_max_energy
	_light.actual_min_energy = actual_min_energy
	
	_lights.append(_light)
	
	add_child(_light, true)
	
	_light.position = pos

func _load_data(data : GStorage) -> void:
	if not data.has_value(Utils.nhash(self) + &"parameters"): return
	
	var _parameters := Utils.string_to_vector3(data.get_value(Utils.nhash(self) + &"parameters"))
	
	actual_max_energy = _parameters.x
	actual_min_energy = _parameters.y
	omni_range = _parameters.z

func _save_data(data : GStorage) -> void:
	data.set_value(Utils.nhash(self) + &"parameters", Vector3(actual_max_energy, actual_min_energy, omni_range))
