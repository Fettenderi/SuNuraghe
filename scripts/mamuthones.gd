@tool
class_name Mamuthones
extends CharacterBody3D

const TURNING_SPEED = 10.0

@export_subgroup("Movement")
@export var distance_threshold := 0.5

@export_subgroup("Patroling")
@export var activation_receiver : ReceiverRes
@export var deactivation_receiver : ReceiverRes
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
@warning_ignore("unused_private_class_variable")
@export_tool_button("Update Waypoints", "Reload") var _update = _update_tooltip

@export_storage var patroling_resource := PatrolingResource.new()

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var _movement_state_machine: StateMachine = %MovementSM
@onready var _collision_shape: CollisionShape3D = %CollisionShape3D
@onready var _mesh: Node3D = %Mesh
@onready var _eyes: Node3D = %Eyes

var _is_active := false:
	set(value):
		_is_active = value
		_collision_shape.set_deferred("disabled", not value)
		visible = value
var speed := 0.0

var end_buffered := false

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
	_setup_patrol_resource()
	
	if show_tooltip:
		_update_tooltip()

	if Engine.is_editor_hint(): return
	
	if activation_receiver != null:
		_is_active = false
		activation_receiver.received.connect(_start_movement.unbind(1))
	else:
		_start_movement()
	
	if deactivation_receiver != null:
		deactivation_receiver.received.connect(_end_movement.unbind(1))

	_setup_arrived_cooldown()
	position = patroling_resource.get_current_target()
	patroling_resource.waypoint_reached()
	_eyes.create_rays(self)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if show_tooltip:
		_target_indicator.position = navigation_agent_3d.target_position
	
	_movement_state_machine.update()
	
	var _destination := navigation_agent_3d.get_next_path_position()
	var _local_destination := _destination - global_position
	
	if Vector2(_local_destination.x, _local_destination.z).length() > distance_threshold:
		_direction = _local_destination.normalized()
		
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, atan2(_direction.x, _direction.z), TURNING_SPEED * delta)
	elif not _on_arrived_cooldown:
		_on_arrived_cooldown = true
		_direction = Vector3.ZERO
		_movement_state_machine.update({"arrived" : true})
	
	
	velocity = _direction * speed * delta
	
	move_and_slide()


func _setup_patrol_resource():
	if patroling_resource != null: return
	
	if Engine.is_editor_hint():
		patroling_resource = PatrolingResource.new()
	else:
		assert(false, "Non dovresti cercare di setuppare una patrol resource on runtime")

func _add_waypoint():
	patroling_resource.waypoints.append(global_position)
	if show_tooltip:
		_update_tooltip()

func _clear_waypoints():
	patroling_resource = null
	
	_setup_patrol_resource()
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


func _start_movement():
	_is_active = true
	_movement_state_machine.start()

func _end_movement():
	_movement_state_machine.update({"end": true})
	queue_free()

func _on_eyes_located(collider: Player) -> void:
	if not _is_active: return
	
	_movement_state_machine.change_state("ChaseState")
	navigation_agent_3d.target_position = collider.position

func _on_kill_box_body_entered(_body: Node3D) -> void:
	if not _is_active: return
	
	get_tree().call_deferred("reload_current_scene")
	#_movement_state_machine.change_state("KillingState")
	#if body is Player:
		#body.start_dying(position)
	#navigation_agent_3d.target_position = body.position

func _setup_arrived_cooldown():
	_arrived_cooldown = Timer.new()
	_arrived_cooldown.one_shot = true
	_arrived_cooldown.autostart = false
	_arrived_cooldown.wait_time = 0.3
	_arrived_cooldown.timeout.connect(_arrived_cooldown_ended)
	add_child(_arrived_cooldown, true)

func _arrived_cooldown_ended():
	_on_arrived_cooldown = false
