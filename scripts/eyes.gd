@tool
extends Node3D

@export var rays_amount := 25:
	set(value):
		rays_amount = value
		_update_rays()
@export var ray_lenght := 15.0:
	set(value):
		ray_lenght = value
		_update_rays()
@export_range(0.0, 1.0, 0.01) var rays_paralellness := 0.5:
	set(value):
		rays_paralellness = value
		_update_rays()
@export_range(0, 180, 1, "radians_as_degrees") var view_angle := TAU / 6:
	set(value):
		view_angle = value
		_update_rays()
@export var tooltip_visible := true:
	set(value):
		tooltip_visible = value
		_update_rays()
@warning_ignore("unused_private_class_variable")
@export_tool_button("Refresh Rays", "Clear") var _reset = _update_rays

@export_flags_3d_physics var rays_collision_mask

var _rays : Array[RayCast3D] = []
var _editor_rays : Array[CSGCylinder3D] = []

var _debug_material : StandardMaterial3D

signal located(collider: Player)
signal not_visible

func _ready() -> void:
	if Engine.is_editor_hint():
		if not tooltip_visible: return
		_create_debug_rays()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	var _seens := 0
	var _player : Player
	for _i in range(len(_rays)):
		if _rays[_i].is_colliding() and _rays[_i].get_collider() is Player:
			_player = _rays[_i].get_collider()
			_seens += 1
	
	if _seens <= 2:
		not_visible.emit()
	else:
		located.emit(_player)

func _update_rays():
	_reset_rays()
	
	if Engine.is_editor_hint():
		if not tooltip_visible: return
		_create_debug_rays()

func create_rays(excluded_collider):
	var _ray_direction : Vector3
	var _ray_offset : Vector3
	var _ray : RayCast3D
	
	for _i in range(rays_amount + 1):
		if _i == 0: continue
		
		var angle = view_angle / (rays_amount + 1) * _i - view_angle / 2.0
		_ray_direction = Vector3(cos(angle), 0.0, sin(angle)) * ray_lenght
		_ray_offset = Vector3(0.0, 0.0, lerp(0.0, _ray_direction.z, rays_paralellness))
		_ray_direction.z -= _ray_offset.z
		_ray = RayCast3D.new()
		_ray.collide_with_areas = false
		_ray.collide_with_bodies = true
		_ray.collision_mask = rays_collision_mask
		_ray.add_exception_rid(excluded_collider.get_rid())
		_ray.position = _ray_offset
		_ray.target_position = _ray_direction
		_rays.append(_ray)
		
		add_child(_ray, true)

func _reset_rays():
	for _ray in get_children():
		_ray.queue_free()
	_rays.clear()


func _create_debug_rays():
	if _debug_material == null:
		_debug_material = StandardMaterial3D.new()
		_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_debug_material.albedo_color = Color("#cafeff40")
	
	var _ray_direction : Vector3
	var _ray_offset : Vector3
	var _ray : CSGCylinder3D
	
	for _i in range(rays_amount + 1):
		if _i == 0: continue
		
		var angle = view_angle / (rays_amount + 1) * _i - view_angle / 2.0
		_ray_direction = Vector3(cos(angle), 0.0, sin(angle)) * ray_lenght
		_ray_offset = Vector3(0.0, 0.0, lerp(0.0, _ray_direction.z, rays_paralellness))
		_ray_direction.z -= _ray_offset.z
		_ray = CSGCylinder3D.new()
		_ray.position = (_ray_offset + _ray_direction) / 2
		_ray.height = (_ray_offset - _ray_direction).length()
		_ray.quaternion = Quaternion(Vector3.UP, (_ray_offset - _ray_direction).normalized())
		_ray.material = _debug_material
		_ray.radius = 0.05
		_editor_rays.append(_ray)
		
		add_child(_ray, true)
