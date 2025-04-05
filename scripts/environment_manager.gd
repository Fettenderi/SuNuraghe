@tool
extends Node3D

@export var _is_enabled := true:
	set(value):
		_is_enabled = value
		
		if not Engine.is_editor_hint(): return
		_update_env()

@onready var _sun : DirectionalLight3D = %Sun
@onready var _environment : Environment = %Environment.environment

func _ready() -> void:
	_update_env()

func set_enabled(value: bool) -> void:
	_is_enabled = value

func _update_env() -> void:
	if _sun != null:
		_sun.light_energy = 1.0 if _is_enabled else 0.0
	if _environment != null:
		_environment.background_energy_multiplier = 1.0 if _is_enabled else 0.1
		_environment.ambient_light_energy = 1.0 if _is_enabled else 0.0
		_environment.sdfgi_enabled = not _is_enabled
