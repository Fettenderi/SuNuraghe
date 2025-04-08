#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_texture;

layout(push_constant, std430) uniform Params {
	vec2 screen_size;
	float inv_proj_2w;
	float inv_proj_3w;
} p;

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec2 size = p.screen_size;
	int down_scaling_factor = 4;

	vec2 uv = pixel * down_scaling_factor / size;

	if (pixel.x >= size.x || pixel.y >= size.y) return;
		
	vec4 color = imageLoad(screen_texture, pixel * down_scaling_factor);
		
	for (int i = 0; i < down_scaling_factor; i++) {
		for (int j = 0; j < down_scaling_factor; j++) {
			imageStore(screen_texture, pixel * down_scaling_factor + ivec2(i, j), color);
		}
	}
}
