shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

void fragment() {
	vec4 tex_color = texture(tex, UV);
	tex_color.r = mod(tex_color.r + time, 1.0);
	tex_color.g = mod(tex_color.g + pow(time, 1.2), 1.0);
	tex_color.b = mod(tex_color.b + pow(time, 1.4), 1.0);
	COLOR = tex_color;
}
