shader_type canvas_item;

uniform float aspect_ratio = 1.0;
uniform vec2 pointer;
uniform sampler2D tex;
uniform float time = 0.0;

const float STRENGTH = 0.12;
const float RADIUS = 0.33;
const float ABERRATION = 0.4;
const float WIDTH = 0.1;
const float FEATHER = 0.2;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

// adapted from: https://godotshaders.com/shader/distortion/
void fragment() {
	vec2 scaled_uv = (UV - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0, 0.5);
	vec2 dist_center2 = scaled_uv - pointer;
	float dist_center = length(dist_center2);
	float mask =  (1.0 - smoothstep(RADIUS - FEATHER, RADIUS, dist_center)) * smoothstep(RADIUS - WIDTH - FEATHER, RADIUS - WIDTH , dist_center);
	vec2 offset = normalize(dist_center2) * STRENGTH * mask;
	vec2 biased_uv = scaled_uv - offset;
	vec2 abber_vec = offset * ABERRATION * mask;
	vec2 final_uv = UV * (1.0 - mask) + biased_uv * mask;
	vec4 red = texture(tex, final_uv + abber_vec);
	vec4 blue = texture(tex, final_uv - abber_vec);
	vec4 ori = texture(tex, final_uv);
	// take the original if we haven't started yet
	float started = has_started(time);
	COLOR = mix(texture(tex, UV), vec4(red.r, ori.g, blue.b, 1.0), started);
}