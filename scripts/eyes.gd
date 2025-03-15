@tool
extends Node3D

const PLAYER_COLLISION_LAYER = 2


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

var excluded_collider : CollisionObject3D

var _rays : Array[RayCast3D] = []
var _ray_weights : Array[float] = []
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
	
	var _seen := false
	for _i in range(len(_rays)):
		if not _seen and _rays[_i].is_colliding() and _rays[_i].get_collider() is Player and _is_visible(_i):
			located.emit(_rays[_i].get_collider())
			_seen = true
	
	if not _seen:
		not_visible.emit()

func _is_visible(index : int) -> bool:
	return _ray_weights[index] <= _rays[index].get_collider().get_visibility()

func _update_rays():
	_reset_rays()
	
	if Engine.is_editor_hint():
		if not tooltip_visible: return
		_create_debug_rays()

func create_rays():
	var _ray_direction : Vector3
	var _ray_offset : Vector3
	var _ray : RayCast3D
	
	for _i in range(rays_amount + 1):
		if _i == 0: continue
		
		var angle = view_angle / (rays_amount + 1) * _i - view_angle / 2.0
		_ray_weights.append(_ease_function(_normalizing_function(angle, view_angle / 2.0)))
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

# Non fa molto ma lo lascio perchè boh
func _normalizing_function(value: float, maxv: float) -> float:
	return abs(abs(value) - maxv)/maxv

func _ease_function(value: float) -> float:
	return 1.0 - (1.0 - value)*(1.0 - value)

func _reset_rays():
	for _ray in get_children():
		_ray.queue_free()
	_rays.clear()
	_ray_weights.clear()


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
