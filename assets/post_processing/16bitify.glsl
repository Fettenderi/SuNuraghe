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
	vec4 color = imageLoad(screen_texture, pixel);
	int factor = 256;
	
	float red = round(color.r * factor) / factor;
	float green = round(color.g * factor) / factor;
	float blue = round(color.b * factor) / factor;

	imageStore(screen_texture, pixel, vec4(red, green, blue, 1.0));
}
