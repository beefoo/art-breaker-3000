shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float SPEED = 16.0;
const float SWIRL_SIZE = 10.0;
const float SWIRL_ARMS = 3.0;
const float SWIRL_CONTRAST = 0.6;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

// https://godotshaders.com/snippet/swirl/
float swirl(vec2 uv, float size, float arms, float t, float speed)
{
	float angle = atan(-uv.y + 0.5, uv.x - 0.5) ;
	float len = length(uv - vec2(0.5, 0.5));
	
	float value = sin(len * size + angle * arms + time * speed);
	return (value + 1.0) / 2.0;
}

void fragment() {
	float started = has_started(time);
	float swirl = swirl(UV, SWIRL_SIZE, SWIRL_ARMS, time, SPEED);
	vec4 color = texture(tex, UV);
	vec4 swirl_color = mix(vec4(color.rgb * (1.0/SWIRL_CONTRAST), 1.0), vec4(color.rgb * SWIRL_CONTRAST, 1.0), swirl);
	COLOR = mix(color, swirl_color, started);
}
