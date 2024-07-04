shader_type canvas_item;

uniform float time = 0.0;

const float SPEED = 0.4;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 shifted_color = tex_color;
	shifted_color.r = mod(UV.x + sin(time) * SPEED, 1.0);
	shifted_color.g = mod(UV.x + cos(time) * SPEED, 1.0);
	shifted_color.b = mod(UV.x + time * SPEED, 1.0);
	COLOR = shifted_color;
}
