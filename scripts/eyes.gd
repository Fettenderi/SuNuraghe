extends Node3D

const PLAYER_COLLISION_LAYER = 2

@export var rays_amount := 25:
	set(value):
		rays_amount = value
		update_rays()
@export var ray_lenght := 15.0:
	set(value):
		ray_lenght = value
		update_rays()
@export_range(0.0, 1.0, 0.01) var rays_paralellness := 0.5:
	set(value):
		rays_paralellness = value
		update_rays()
@export_range(0, 180, 1, "radians_as_degrees") var view_angle := TAU / 6:
	set(value):
		view_angle = value
		update_rays()

@export var reset_rays := false:
	set(value):
		for _ray in get_children():
			_ray.queue_free()
		_rays.clear()

@export_flags_2d_physics var player_collision_mask = PLAYER_COLLISION_LAYER

var _rays : Array[RayCast3D]

signal located(collider)
signal not_visible

func _ready() -> void:
	create_rays()

func update_rays():
	for _ray in _rays:
		_ray.queue_free()
	_rays.clear()
	
	create_rays()

func create_rays():
	var _ray_direction : Vector3
	var _ray_offset : Vector3
	var _ray : RayCast3D
	
	for _i in range(rays_amount):
		var angle = view_angle / rays_amount * _i - view_angle / 2.0
		_ray_direction = Vector3(cos(angle), 0.0, sin(angle)) * ray_lenght
		_ray_offset = Vector3(0.0, 0.0, lerp(0.0, _ray_direction.z, rays_paralellness))
		_ray_direction.z -= _ray_offset.z
		_ray = RayCast3D.new()
		_ray.collide_with_areas = false
		_ray.collide_with_bodies = true
		_ray.position = _ray_offset
		_ray.target_position = _ray_direction
		_rays.append(_ray)
		
		add_child(_ray, true)

func _physics_process(_delta: float) -> void:
	var _seen := false
	for _ray in _rays:
		if not _seen and _ray.is_colliding() and _ray.get_collider() is Player:
			located.emit(_ray.get_collider())
			_seen = true
	
	if not _seen:
		not_visible.emit()
