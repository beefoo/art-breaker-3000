shader_type canvas_item;

uniform float time = 0.0;

const float BASE_SPEED = 0.005; // increase to be faster
const float BANDS = 256.0; // number of bands

void fragment() {
	float band_size = 1.0 / BANDS;
	// determine which row/band this is
	float band = floor(UV.y / band_size);
	// alternate directions based on odd/even rows
	float direction = 1.0 - mod(band, 2.0) * 2.0;
	// make rows that are closer to center, faster
	float center_band = floor(0.5 / band_size);
	float band_multiplier = (BANDS - abs(center_band - band)) / BANDS;
	// animate based on time, base speed, pointer multiplier, acceleration, and direction
	float x = mod(UV.x + (pow(time, band_multiplier) * BASE_SPEED * direction), 1.0);
	COLOR = texture(TEXTURE, vec2(x, UV.y));
}