@tool
class_name AbstractEffect extends CompositorEffect

@export_file("*.glsl") var glsl_file : String

var rd : RenderingDevice
var shader : RID
var pipeline : RID

func _init() -> void:
	RenderingServer.call_on_render_thread(initialize_compute_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and shader.is_valid():
		RenderingServer.free_rid(shader)

func initialize_compute_shader() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd: return
	
	#_check_shader()
	
func _check_shader() -> bool:
	if shader.is_valid():
		RenderingServer.free_rid(shader)
	
	if glsl_file == "": return false
	var glsl_shader : RDShaderFile = load(glsl_file)
	
	shader = rd.shader_create_from_spirv(glsl_shader.get_spirv())
	pipeline = rd.compute_pipeline_create(shader)
	if not shader.is_valid(): return false

	return pipeline.is_valid()

func get_uniform(rids : Array[RID], type : RenderingDevice.UniformType, binding := 0) -> RDUniform:
	var uniform : RDUniform = RDUniform.new()
	uniform.uniform_type = type
	uniform.binding = binding
	for rid : RID in rids:
		uniform.add_id(rid)
	return uniform

func get_sampler(type : RenderingDevice.SamplerFilter) -> RID:
	var sampler_state : RDSamplerState = RDSamplerState.new()
	sampler_state.min_filter = type
	sampler_state.mag_filter = type
	return rd.sampler_create(sampler_state)
