shader_type canvas_item;

uniform vec2 pointer;
uniform sampler2D tex;
uniform float time = 0.0;

const float SATURATION = 0.33;
const float SHIFT_MULTIPLIER = 3.0; // higher number = more color bands
const float COLORFULNESS = 0.5; // higher number = more, different colors

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	float started = has_started(time);
	vec4 pointer_color = texture(tex, pointer);
	float pointer_dist = mod(length(UV - pointer), 1.0);
	vec4 tex_color = texture(tex, UV);
	vec4 shifted_color = tex_color;
	shifted_color.r = mod(shifted_color.r + pointer_dist * SHIFT_MULTIPLIER, 1.0);
	shifted_color.g = mod(shifted_color.g + pointer_dist * SHIFT_MULTIPLIER * (1.0 + COLORFULNESS), 1.0);
	shifted_color.b = mod(shifted_color.b + pointer_dist * SHIFT_MULTIPLIER * (1.0 + COLORFULNESS * 2.0), 1.0);
	COLOR = mix(tex_color, shifted_color, SATURATION * started);
}
