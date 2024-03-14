shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float MULTIPLY_X = 2.0;
const float MULTIPLY_Y = 2.0;
const float WOBBLE_AMOUNT = 0.1;
const float WOBBLE_SPEED = 32.0;

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment() {
	if (time > 0.0) {
		float x = mod(UV.x * MULTIPLY_X, 1.0);
		float y = mod(UV.y * MULTIPLY_Y, 1.0);
		float wobble = sin(time * WOBBLE_SPEED) * WOBBLE_AMOUNT + PI * 0.5;
		vec2 rotated_uv = rotate(vec2(x, y), vec2(0.5, 0.5), wobble);
		COLOR = texture(tex, rotated_uv);
	} else {
		COLOR = texture(tex, UV);
	}	
}