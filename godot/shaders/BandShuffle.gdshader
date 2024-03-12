shader_type canvas_item;

uniform float speed = 1.0;
uniform sampler2D tex;
uniform float time = 0.0;

const float BAND_SIZE = 0.1;

void fragment() {
	int row = int(floor(UV.y / BAND_SIZE));
	float direction = row % 2 < 1 ? 1.0 : -1.0;
	float x = mod(UV.x + (time * speed * direction), 1.0);
	COLOR = texture(tex, vec2(x, UV.y));
}