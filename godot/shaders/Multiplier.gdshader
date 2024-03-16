shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float MULTIPLY_X = 2.0;
const float MULTIPLY_Y = 2.0;
const float WOBBLE_AMOUNT = 0.1;
const float WOBBLE_SPEED = 32.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment() {
	float started = has_started(time);
	// 1.0 if not started, MULTIPLY_X if started
	float multiply_x = started * (MULTIPLY_X - 1.0) + 1.0;
	float multiply_y = started * (MULTIPLY_Y - 1.0) + 1.0;
	float x = mod(UV.x * multiply_x, 1.0);
	float y = mod(UV.y * multiply_y, 1.0);
	float wobble = sin(time * WOBBLE_SPEED) * WOBBLE_AMOUNT + PI * 0.5;
	vec2 rotated_uv = mod(rotate(vec2(x, y), vec2(0.5, 0.5), wobble), 1.0);
	COLOR = texture(tex, rotated_uv);
}