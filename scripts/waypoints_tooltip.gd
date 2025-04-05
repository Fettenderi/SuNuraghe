@tool
extends Node

@export var show_tooltip := true:
	set(value):
		if not Engine.is_editor_hint(): return
		
		show_tooltip = value
		if not show_tooltip:
			_clear_tooltip()
		else:
			_update_tooltip()

var _waypoints : Array[Marker3D] = []

var _sphere_container : Node
var _spheres : Array[CSGSphere3D] = []
var _lines : Array[CSGCylinder3D] = []

var _line_debug_material : StandardMaterial3D = StandardMaterial3D.new()
var _waypoint_debug_material : StandardMaterial3D = StandardMaterial3D.new()
var _target_debug_material : StandardMaterial3D = StandardMaterial3D.new()

func _ready() -> void:
	if not Engine.is_editor_hint(): return
	
	for _marker : Marker3D in get_children():
		_waypoints.append(_marker)
	
	if show_tooltip:
		_update_tooltip()


func _update_tooltip() -> void:
	if _sphere_container == null:
		_sphere_container = Node.new()
		_sphere_container.name = "SphereContainer"
		add_child(_sphere_container, true)

		_line_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_waypoint_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_target_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		_line_debug_material.albedo_color = Color("#ffffff40")
		_waypoint_debug_material.albedo_color = Color("#33beff40")
		_target_debug_material.albedo_color = Color("#ff00007e")

	
	_clear_tooltip()
	
	for _marker : Marker3D in _waypoints:
		_create_sphere(_marker.position, _waypoint_debug_material, 0.3)
	
	for _i in range(len(_spheres) - 1):
		_create_line(_spheres[_i].position, _spheres[_i + 1].position, _line_debug_material)

func _clear_tooltip() -> void:
	for _sph in _spheres:
		_sph.queue_free()
	_spheres.clear()

	for _lin in _lines:
		_lin.queue_free()
	_lines.clear()


func _create_sphere(pos : Vector3, mat : Material, radius : float) -> CSGSphere3D:
	var _sphere := CSGSphere3D.new()
	_sphere.radius = radius
	_sphere.position = pos
	_sphere.material = mat
	_spheres.append(_sphere)
	_sphere_container.add_child(_sphere, true)
	
	return _sphere

func _create_line(from : Vector3, to : Vector3, mat : Material) -> void:
	var _line := CSGCylinder3D.new()
	_line.radius = 0.15
	_line.height = (from - to).length()
	_line.position = (from + to) / 2
	_line.quaternion = Quaternion(Vector3.UP, (from - to).normalized())
	_line.material = mat
	_lines.append(_line)
	_sphere_container.add_child(_line, true)

	_line = CSGCylinder3D.new()
	_line.cone = true
	_line.radius = 0.3
	_line.height = 0.6
	_line.position = (from + to) / 2
	_line.quaternion = Quaternion(Vector3.DOWN, (from - to).normalized())
	_line.material = mat
	_lines.append(_line)
	_sphere_container.add_child(_line, true)
