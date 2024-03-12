shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 0.1; // increase to be faster
const float BAND_SIZE = 0.1; // 0.1 = 10 bands
const float ACCELARATION = 1.2; // 1.0 linear time; < 1.0 will slow down; > 1.0 will speed up

void fragment() {
	// determine which row/band this is
	int row = int(floor(UV.y / BAND_SIZE));
	// alternate directions based on odd/even rows
	float direction = row % 2 < 1 ? 1.0 : -1.0;
	// make rows that are closer to center, faster
	float center_row = floor(0.5 / BAND_SIZE);
	float bands = 1.0 / BAND_SIZE;
	float row_multiplier = (bands - abs(center_row - float(row))) / bands;
	// animate based on time, base speed, pointer multiplier, acceleration, and direction
	float x = mod(UV.x + (pow(time, (ACCELARATION + row_multiplier)) * BASE_SPEED * direction), 1.0);
	COLOR = texture(tex, vec2(x, UV.y));
}