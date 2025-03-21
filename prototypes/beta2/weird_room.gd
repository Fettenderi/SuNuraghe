@tool
extends CSGBox3D

@export var direction : Vector3
@export var target : CharacterBody3D

@onready var _start: Marker3D = %Start
@onready var _end: Marker3D = %End

var _starting_position : Vector3
var _starting_size : Vector3

var _tooltip_shape : CSGBox3D
var _tooltip_material : StandardMaterial3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_starting_position = position
	_starting_size = size
	
	if target == null:
		print("STANZA STRANA NON COLLEGATA " + name)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_tooltip_shape()
		return
	
	if target == null: return
	
	position = lerp(position, _starting_position + _get_difference_vector(direction) / 2.0, 1.0 - exp(-delta * 3.0))
	size = lerp(size, _starting_size + _get_difference_vector(direction), 1.0 - exp(-delta * 2.0))

func _get_difference_vector(dir : Vector3):
	return (clamp(target.position.dot(dir), _start.position.dot(dir), _end.position.dot(dir)) - _start.position.dot(dir)) * dir

func _update_tooltip_shape():
	if _tooltip_shape == null:
		_tooltip_shape = CSGBox3D.new()
		_tooltip_shape.flip_faces = true
		add_child(_tooltip_shape, true)
		
		_tooltip_material = StandardMaterial3D.new()
		
		_tooltip_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_tooltip_material.albedo_color = Color("#ffffff40")
		
		_tooltip_shape.material = _tooltip_material
	
	_tooltip_shape.position = position + _get_difference_vector(-direction) / 2.0
	_tooltip_shape.size = size + _get_difference_vector(-direction)
