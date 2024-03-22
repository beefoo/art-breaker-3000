shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 1.0; // increase to be faster
const float ACCELERATION = 0.5; // > 1.0 will move faster over time, < 1.0 will be slower over time

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment() {
	// convert to polar coordinates
	vec2 center = vec2(0.5);
	vec2 shift_uv = UV - center;
	float radius = sqrt(dot(shift_uv, shift_uv));
	float angle = atan(shift_uv.y, shift_uv.x);
	
	// move pixel towards the center
	float new_radius = radius + pow(time * BASE_SPEED, ACCELERATION);
	// convert back to UV
	vec2 new_uv = vec2(cos(angle), sin(angle)) * new_radius + center;
	new_uv = mod(new_uv, 1.0);
	
	COLOR = texture(tex, new_uv);
}