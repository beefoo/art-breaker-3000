shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const int RES_X = 64;
const int RES_Y = 64;
const float TWINKLE_SPEED = 16.0;
const float TWINKLE_BRIGHTNESS = 0.1;

// 0.100392156862 is the cube root of 255
const vec3 rgb255 = vec3(0.100392156862, 0.100392156862, 0.100392156862);

// https://godotshaders.com/snippet/random-value/
float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

// adapted from: https://godotshaders.com/shader/256-colour-pixelation/
void fragment() {
	float started = has_started(time);
	float uvX = UV.x - mod(UV.x * float(RES_X), 1) / float(RES_X) * started;
	float uvY = UV.y - mod(UV.y * float(RES_Y), 1) / float(RES_Y) * started;
	vec2 grid_uv = vec2(uvX, uvY);
	vec4 color = texture(tex, grid_uv);
	vec3 remainder = mod(color.rgb, rgb255) * started;
	color.rgb = color.rgb - remainder;
	float rand = max(random(grid_uv), 0.1);
	float pulse = (sin(time * TWINKLE_SPEED * rand) + 1.0) / 2.0;
	vec4 brightened = vec4(min(color.rgb + vec3(TWINKLE_BRIGHTNESS), vec3(1.0)), 1.0);
	COLOR = mix(color, brightened, rand * pulse * started);
}