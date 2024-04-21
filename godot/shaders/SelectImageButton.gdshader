shader_type canvas_item;

uniform sampler2D from_tex;
uniform sampler2D to_tex;
uniform float transition = 0.0;
uniform float aspect = 1.0;
uniform float from_tex_aspect = 1.0;
uniform float to_tex_aspect = 1.0;

const float X_ANCHOR = 0.5;
const float Y_ANCHOR = 0.2;

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	// from tex is more horizontal than container
	vec2 uv_from_horz = UV;
	float from_w = aspect / from_tex_aspect;
	float from_x = (1.0 - from_w) * X_ANCHOR;
	uv_from_horz.x = mix(from_x, from_x + from_w, UV.x);
	
	// tex is more vertical than container
	vec2 uv_from_vert = UV;
	float from_h = from_tex_aspect / aspect;
	float from_y = (1.0 - from_h) * Y_ANCHOR;
	uv_from_vert.y = mix(from_y, from_y + from_h, UV.y);
	
	// check if tex is more horizontal or vertical than container
	vec2 uv_from = mix(uv_from_vert, uv_from_horz, when_gt(from_tex_aspect, aspect));
	vec4 color_from = texture(from_tex, uv_from);
	
	// to tex is more horizontal than container
	vec2 uv_to_horz = UV;
	float to_w = aspect / to_tex_aspect;
	float to_x = (1.0 - to_w) * X_ANCHOR;
	uv_to_horz.x = mix(to_x, to_x + to_w, UV.x);
	
	// tex is more vertical than container
	vec2 uv_to_vert = UV;
	float to_h = to_tex_aspect / aspect;
	float to_y = (1.0 - to_h) * Y_ANCHOR;
	uv_to_vert.y = mix(to_y, to_y + to_h, UV.y);
	
	// check if tex is more horizontal or vertical than container
	vec2 uv_to = mix(uv_to_vert, uv_to_horz, when_gt(to_tex_aspect, aspect));
	vec4 color_to = texture(to_tex, uv_to);
	
	COLOR = mix(color_from, color_to, transition);
}
