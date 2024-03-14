shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

void fragment() {
	COLOR = texture(tex, UV);
}
