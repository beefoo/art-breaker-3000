shader_type canvas_item;

uniform float aspect_ratio;
uniform vec2 pointer_start;
uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 1.5; // increase to be faster
const float BANDS = 8.0; // number of bands
const float ACCELARATION = 1.05; // 1.0 linear time; < 1.0 will slow down; > 1.0 will speed up

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	vec2 scaled_uv_horz = (UV - vec2(0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0, 0.5);
	vec2 scaled_uv_vert = (UV - vec2(0.5, 0)) / vec2(1.0 / aspect_ratio, 1.0) + vec2(0.5, 0);
	vec2 scaled_uv = mix(scaled_uv_vert, scaled_uv_horz, when_gt(aspect_ratio, 1.0));
	
	float band_size = 1.0 / BANDS;
	float dist = length(scaled_uv - pointer_start);
	// determine which band this is
	float band = floor(dist / band_size);
	// alternate directions based on odd/even bands
	float direction = 1.0 - mod(band, 2.0) * 2.0;
	float angle = pow(time, ACCELARATION) * BASE_SPEED * direction + PI * 0.5;
	vec2 rotated_uv = mod(rotate(UV, pointer_start, angle), 1.0);
	COLOR = texture(tex, rotated_uv);
}