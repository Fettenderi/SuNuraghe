@tool
class_name Mamuthones
extends Creature

@export var show_tooltip := true:
	set(value):
		show_tooltip = value
		if not show_tooltip:
			_clear_tooltip()
		else:
			_update_tooltip()

@warning_ignore("unused_private_class_variable")
@export_tool_button("Add Waypoint", "Add") var _add_waypoint_button = _add_waypoint
@warning_ignore("unused_private_class_variable")
@export_tool_button("Clear Waypoints", "Clear") var _clear__button = _clear_waypoints
@warning_ignore("unused_private_class_variable")
@export_tool_button("Update Waypoints", "Reload") var _update_tooltip_button = _update_tooltip

@export_storage var patroling_resource := PatrolingResource.new()

var _sphere_container : Node
var _target_indicator : CSGSphere3D
var _spheres : Array[CSGSphere3D] = []
var _lines : Array[CSGCylinder3D] = []

var _line_debug_material : StandardMaterial3D = StandardMaterial3D.new()
var _waypoint_debug_material : StandardMaterial3D = StandardMaterial3D.new()
var _target_debug_material : StandardMaterial3D = StandardMaterial3D.new()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_setup_patrol_resource()
	
	if show_tooltip:
		_update_tooltip()
	
	super()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	super(delta)
	
	if not show_tooltip: return
	_target_indicator.position = navigation_agent_3d.target_position


func _setup_patrol_resource() -> void:
	if patroling_resource != null: return
	
	if Engine.is_editor_hint():
		patroling_resource = PatrolingResource.new()
	else:
		assert(false, "Non dovresti cercare di setuppare una patrol resource on runtime")

func _add_waypoint() -> void:
	patroling_resource.waypoints.append(global_position)
	if show_tooltip:
		_update_tooltip()

func _clear_waypoints() -> void:
	patroling_resource = null
	
	_setup_patrol_resource()
	if show_tooltip:
		_update_tooltip()

func _clear_tooltip() -> void:
	for _sph in _spheres:
		_sph.queue_free()
	_spheres.clear()

	for _lin in _lines:
		_lin.queue_free()
	_lines.clear()

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
	
	if patroling_resource == null:
		assert(false, "Patroling resource mancante")
	
	for _pos in patroling_resource.waypoints:
		_create_sphere(_pos, _waypoint_debug_material, 0.3)
	
	for _i in range(len(_spheres) - 1):
		_create_line(_spheres[_i].position, _spheres[_i + 1].position, _line_debug_material)

	if len(_spheres) > 2:
		_create_line(_spheres[len(_spheres) - 1].position, _spheres[0].position, _line_debug_material)
	
	if not Engine.is_editor_hint():
		_target_indicator = _create_sphere(position, _target_debug_material, 0.4)

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
