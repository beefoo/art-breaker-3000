shader_type canvas_item;

uniform vec2 pointer_start = vec2(0.5);
uniform vec2 pointer = vec2(0.5);
uniform sampler2D tex;
uniform float time = 0.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	float started = has_started(time);
	
	vec4 color = texture(tex, UV);
	float brightness = (color.r + color.g + color.b) / 3.0;
	
	// shift UV based on pixel brightness
	vec2 delta = (pointer - pointer_start) * brightness;
	vec2 shifted_uv = mod(UV - delta, 1.0);
	
	// take the original UV if not started
	vec2 final_uv = mix(UV, shifted_uv, started);
	COLOR = texture(tex, final_uv);
}