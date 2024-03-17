shader_type canvas_item;

uniform vec2 pointer = vec2(0.0);
uniform sampler2D tex;
uniform float time = 0.0;

const float SEGMENTS = 6.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

// Adapted from: https://danielilett.com/2020-02-19-tut3-8-crazy-kaleidoscopes/
void fragment() {
	float started = has_started(time);
	// convert to polar coordinates
	vec2 shift_uv = UV - pointer;
	float radius = sqrt(dot(shift_uv, shift_uv));
	float angle = atan(shift_uv.y, shift_uv.x);
	// Calculate segment angle amount
	float segment_angle = 2.0 * PI / SEGMENTS;
	// Calculate which segment this angle is in
	angle -= segment_angle * floor(angle / segment_angle);
	// Each segment contains one reflection.
	angle = min(angle, segment_angle - angle);
	// Convert back to UV coordinates.
	vec2 new_uv = vec2(cos(angle), sin(angle)) * radius + pointer;
	// Reflect outside the inner circle boundary.
	new_uv = max(min(new_uv, 2.0 - new_uv), -new_uv);
	// take the original UV if we didn't start yet
	vec2 final_uv = mix(UV, new_uv, started);
	COLOR = texture(tex, final_uv);
}