shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 0.5; // increase to be faster
const float BANDS = 10.0; // number of bands
const float ACCELARATION = 1.05; // 1.0 linear time; < 1.0 will slow down; > 1.0 will speed up

void fragment() {
	float band_size = 1.0 / BANDS;
	// determine which row/band this is
	float row = floor(UV.y / band_size);
	// alternate directions based on odd/even rows
	float direction = 1.0 - mod(row, 2.0) * 2.0;
	// make rows that are closer to center, faster
	float center_row = floor(0.5 / band_size);
	float row_multiplier = (BANDS - abs(center_row - row)) / BANDS;
	// animate based on time, base speed, pointer multiplier, acceleration, and direction
	float x = mod(UV.x + (pow(time, (ACCELARATION + row_multiplier)) * BASE_SPEED * direction), 1.0);
	COLOR = texture(tex, vec2(x, UV.y));
}