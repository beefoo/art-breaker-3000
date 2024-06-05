shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float SATURATION = 0.66;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	vec4 tex_color = texture(tex, UV);
	vec4 shifted_color = tex_color;
	shifted_color.r = mod(shifted_color.r + time, 1.0);
	shifted_color.g = mod(shifted_color.g + time * 1.2, 1.0);
	shifted_color.b = mod(shifted_color.b + time * 1.4, 1.0);
	float started = has_started(time);
	COLOR = mix(tex_color, shifted_color, SATURATION * started);
}
