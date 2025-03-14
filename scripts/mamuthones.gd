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

@warning_ignore("unused_private_class_variable")
@export_tool_button("Add Waypoint", "Add") var _add = _add_waypoint
@warning_ignore("unused_private_class_variable")
@export_tool_button("Clear Waypoints", "Clear") var _clear = _clear_waypoints
@export var patroling_resource : PatrolingResource:
	set(value):
		patroling_resource = value
		patroling_resource.changed.connect(_update_tooltip)
		_update_tooltip()

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var _movement_state_machine: StateMachine = %MovementSM
@onready var _mesh: Node3D = %Mesh

var _direction : Vector3

var _sphere_container : Node
var _target_indicator : CSGSphere3D
var _spheres : Array[CSGSphere3D] = []
var _lines : Array[CSGCylinder3D] = []

var _line_debug_material : StandardMaterial3D = StandardMaterial3D.new()
var _waypoint_debug_material : StandardMaterial3D = StandardMaterial3D.new()
var _target_debug_material : StandardMaterial3D = StandardMaterial3D.new()

var _arrived_cooldown : Timer
var _on_arrived_cooldown := false:
	set(value):
		if _on_arrived_cooldown == value: return
		
		_on_arrived_cooldown = value
		if _on_arrived_cooldown: _arrived_cooldown.start()

func _ready() -> void:
	_setup_arrived_cooldown()
	if not Engine.is_editor_hint():
		position = patroling_resource.get_current_target()
		#patroling_resource.waypoint_reached()
	else:
		if show_tooltip:
			_update_tooltip()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if show_tooltip:
		_target_indicator.position = navigation_agent_3d.target_position
	_movement_state_machine.update()
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	
	if Vector2(_local_destination.x, _local_destination.z).length() > distance_threshold:
		_direction = _local_destination.normalized()
		_mesh.rotation.y = atan2(_direction.x, _direction.z) - PI / 2
	elif not _on_arrived_cooldown:
		_on_arrived_cooldown = true
		_direction = Vector3.ZERO
		_movement_state_machine.update({"arrived" : true})
	
	
	velocity = _direction * speed * delta
	
	move_and_slide()


func _add_waypoint():
	patroling_resource.waypoints.append(global_position)
	if show_tooltip:
		_update_tooltip()

func _clear_waypoints():
	patroling_resource.waypoints.clear()
	if show_tooltip:
		_update_tooltip()


func _on_eyes_located(collider: Player) -> void:
	_movement_state_machine.change_state("ChaseState")
	navigation_agent_3d.target_position = collider.position

func _on_kill_box_body_entered(body: Node3D) -> void:
	pass
	#_movement_state_machine.change_state("KillingState")
	#if body is Player:
		#body.start_dying(position)
	#navigation_agent_3d.target_position = body.position


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

		_line_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_waypoint_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_target_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		_line_debug_material.albedo_color = Color("#ffffff40")
		_waypoint_debug_material.albedo_color = Color("#33beff40")
		_target_debug_material.albedo_color = Color("#ff00007e")

	_clear_tooltip()
	
	if patroling_resource == null: return
	
	for _pos in patroling_resource.waypoints:
		_create_sphere(_pos, _waypoint_debug_material, 0.3)
	
	for _i in range(len(_spheres) - 1):
		_create_line(_spheres[_i].position, _spheres[_i + 1].position, _line_debug_material)

	if len(_spheres) > 2:
		_create_line(_spheres[len(_spheres) - 1].position, _spheres[0].position, _line_debug_material)
	
	if not Engine.is_editor_hint():
		_target_indicator = _create_sphere(position, _target_debug_material, 0.4)

func _setup_arrived_cooldown():
	if Engine.is_editor_hint(): return
	
	_arrived_cooldown = Timer.new()
	_arrived_cooldown.one_shot = true
	_arrived_cooldown.autostart = false
	_arrived_cooldown.wait_time = 0.3
	_arrived_cooldown.timeout.connect(_arrived_cooldown_ended)
	add_child(_arrived_cooldown, true)

func _arrived_cooldown_ended():
	_on_arrived_cooldown = false


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
