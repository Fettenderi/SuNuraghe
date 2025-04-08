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
		_update_parameters()

@export var actual_min_energy := 0.2:
	set(value):
		actual_min_energy = value
		_update_parameters()

var _lights : Array[FlickeringLight] = []

func _ready() -> void:
	_update_tooltip()

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
