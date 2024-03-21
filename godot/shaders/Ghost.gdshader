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
	vec2 delta = pointer - pointer_start;
	float dist = 1.0 - length(UV - pointer_start);
	
	// move the pixel with the pointer
	// move more the closer the pixel is to pointer start
	float x = mod(UV.x - delta.x * dist, 1.0);
	float y = mod(UV.y - delta.y * dist, 1.0);
	
	// take the original UV if we didn't start yet
	vec2 new_uv = mix(UV, vec2(x, y), started);
	// mix with the original based on distance from pointer start
	COLOR = mix(texture(tex, UV), texture(tex, new_uv), clamp(dist, 0.0, 1.0));
}