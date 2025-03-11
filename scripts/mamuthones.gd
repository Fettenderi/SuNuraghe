@tool
class_name Mamuthones
extends CharacterBody3D

@export_subgroup("Movement")
@export var speed := 300.0
@export var distance_threshold := 0.5

@export_subgroup("Patroling")
@export var show_tooltip := true:
	set(value):
		show_tooltip = value
		if not show_tooltip:
			_clear_tooltip()
		else:
			_update_tooltip()
		
@export_tool_button("Add Waypoint", "Add") var _add = _add_waypoint
@export_tool_button("Clear Waypoints", "Clear") var _clear = _clear_waypoints
@export var _patroling_resource : PatrolingResource:
	set(value):
		_patroling_resource = value
		_patroling_resource.changed.connect(_update_tooltip)
		_update_tooltip()

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

@onready var _mesh: Node3D = %Mesh

var _direction : Vector3

var _sphere_container : Node
var _spheres : Array[CSGSphere3D] = []
var _lines : Array[CSGCylinder3D] = []
var _sphere_material : StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	if not Engine.is_editor_hint():
		position = _patroling_resource.get_current_target()
	else:
		if show_tooltip:
			_update_tooltip()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	
	if _local_destination.length() > distance_threshold:
		_direction = _local_destination.normalized()
		_mesh.rotation.y = atan2(_direction.x, _direction.z) - 1
		
		# Perchè devo sottrarre questo 1 arbitrario ???????????
	else:
		_direction = Vector3.ZERO
	
	velocity = _direction * speed * delta
	
	move_and_slide()


func _add_waypoint():
	_patroling_resource.waypoints.append(global_position)
	if show_tooltip:
		_update_tooltip()

func _clear_waypoints():
	_patroling_resource.waypoints.clear()
	if show_tooltip:
		_update_tooltip()

func _clear_tooltip():
	for _sph in _spheres:
		_sph.queue_free()
	_spheres.clear()

	for _lin in _lines:
		_lin.queue_free()
	_lines.clear()


func _update_tooltip():
	if _sphere_container == null:
		_sphere_container = Node.new()
		_sphere_container.name = "SphereContainer"
		add_child(_sphere_container, true)
		
		_sphere_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_sphere_material.albedo_color = Color("#cafeff40")

	var _sphere : CSGSphere3D
	var _line : CSGCylinder3D
	
	_clear_tooltip()
	
	for _pos in _patroling_resource.waypoints:
		_sphere = CSGSphere3D.new()
		_sphere.radius = 0.3
		_sphere.position = _pos
		_sphere.material = _sphere_material
		_spheres.append(_sphere)
		_sphere_container.add_child(_sphere, true)
	
	for _i in range(len(_spheres) - 1):
		_line = CSGCylinder3D.new()
		_line.radius = 0.15
		_line.height = (_spheres[_i].position - _spheres[_i + 1].position).length()
		_line.position = (_spheres[_i].position + _spheres[_i + 1].position) / 2
		_line.quaternion = Quaternion(Vector3.UP, (_spheres[_i].position - _spheres[_i + 1].position).normalized())
		_line.material = _sphere_material
		_lines.append(_line)
		_sphere_container.add_child(_line, true)

		_line = CSGCylinder3D.new()
		_line.cone = true
		_line.radius = 0.3
		_line.height = 0.6
		_line.position = (_spheres[_i].position + _spheres[_i + 1].position) / 2
		_line.quaternion = Quaternion(Vector3.DOWN, (_spheres[_i].position - _spheres[_i + 1].position).normalized())
		_line.material = _sphere_material
		_lines.append(_line)
		_sphere_container.add_child(_line, true)

	if len(_spheres) <= 2: return
	var _i = len(_spheres) - 1
	
	_line = CSGCylinder3D.new()
	_line.radius = 0.15
	_line.height = (_spheres[_i].position - _spheres[0].position).length()
	_line.position = (_spheres[_i].position + _spheres[0].position) / 2
	_line.quaternion = Quaternion(Vector3.UP, (_spheres[_i].position - _spheres[0].position).normalized())
	_line.material = _sphere_material
	_lines.append(_line)
	_sphere_container.add_child(_line, true)

	_line = CSGCylinder3D.new()
	_line.cone = true
	_line.radius = 0.3
	_line.height = 0.6
	_line.position = (_spheres[_i].position + _spheres[0].position) / 2
	_line.quaternion = Quaternion(Vector3.DOWN, (_spheres[_i].position - _spheres[0].position).normalized())
	_line.material = _sphere_material
	_lines.append(_line)
	_sphere_container.add_child(_line, true)
