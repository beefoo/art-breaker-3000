shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float WAVE_HEIGHT = 0.05;
const float WAVE_SPEED = 8.0;
const float WAVE_FREQUENCY = 30.0;
const float HORIZONTAL_SPEED = 16.0;
const float HORIZONTAL_DISTANCE = 0.05;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	float started = has_started(time);
	
	float x = mod(UV.x + sin(time * HORIZONTAL_SPEED) * HORIZONTAL_DISTANCE, 1.0);
	float y = mod(UV.y + sin(time * WAVE_SPEED) * WAVE_HEIGHT * sin(UV.x * WAVE_FREQUENCY), 1.0);
	
	// take the original UV if we didn't start yet
	vec2 new_uv = mix(UV, vec2(x, y), started);
	COLOR = texture(tex, new_uv);
}