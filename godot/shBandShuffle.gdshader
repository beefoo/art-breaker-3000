shader_type canvas_item;

uniform float speed = 1.0;
uniform sampler2D tex;
uniform float time = 0.0;

void fragment() {
	//COLOR = texture(tex, UV);
	float x = mod(UV.x + (time * speed), 1.0);
	COLOR = texture(tex, vec2(x, UV.y));
}