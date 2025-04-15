@tool
class_name SimpleEffect extends AbstractEffect

func _render_callback(_effect_callback_type: int, render_data: RenderData) -> void:
	if not rd or not _check_shader(): return

	var scene_buffers : RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	var scene_data : RenderSceneDataRD = render_data.get_render_scene_data()
	if not scene_buffers or not scene_data: return
	
	var size : Vector2i = scene_buffers.get_internal_size()
	if size.x == 0 or size.y == 0: return
	
	@warning_ignore("integer_division")
	var x_group : int = size.x / 16 + 1
	@warning_ignore("integer_division")
	var y_group : int = size.y / 16 + 1
	
	var push_constants : PackedFloat32Array = PackedFloat32Array()
	
	push_constants.append(size.x)
	push_constants.append(size.y)
	push_constants.append(0.0)
	push_constants.append(0.0)
	
	for view in scene_buffers.get_view_count():
		var screen_texture : RID = scene_buffers.get_color_layer(view)
		var uniform : RDUniform = RDUniform.new()
		
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(screen_texture)
		
		var image_uniform_set : RID = UniformSetCacheRD.get_cache(shader, 0, [uniform])
		
		var compute_list : int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, image_uniform_set, 0)
		rd.compute_list_set_push_constant(compute_list, push_constants.to_byte_array(), push_constants.size() * 4)
		rd.compute_list_dispatch(compute_list, x_group, y_group, 1)
		rd.compute_list_end()
