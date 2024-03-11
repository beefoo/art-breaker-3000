shader_type canvas_item;

uniform float speed = 1.0;
uniform sampler2D tex;
uniform float time = 0.0;

void fragment() {
	float y = mod(UV.y + (time * speed), 1.0);
	COLOR = texture(tex, vec2(UV.x, y));
}