shader_type canvas_item;

uniform vec2 pointer_start;
uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 0.5; // increase to be faster
const float DIAGONAL = 0.7071067812; // distance from center to corner
const float SPEED_MULTIPLIER = 8.0; // pixels closer to center move faster

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment() {
	vec2 center = vec2(0.5);
	float dist = length(UV - center);
	float n_dist = clamp(1.0 - dist / 0.5, 0.0, 1.0); // normalize distance
	float angle = time * pow(SPEED_MULTIPLIER, n_dist) * BASE_SPEED + PI * 0.5;
	vec2 rotated_uv = mod(rotate(UV, center, angle), 1.0);
	COLOR = texture(tex, rotated_uv);
}