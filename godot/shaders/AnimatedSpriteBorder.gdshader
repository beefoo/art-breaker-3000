shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.97, 0.87, 0.22, 1.0);

const float COLS = 1.0; // we assume sprite sheet is one column and square frames
const float OUTLINE_THICKNESS = 0.05;

void fragment() {
	float aspect_ratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
	float rows = COLS * aspect_ratio;
	
	float row_h = 1.0 / rows;
	float col_w = 1.0 / COLS;
	float col = floor(UV.x / col_w);
	float row = floor(UV.y / row_h);
	
	float x0 = col * col_w;
	float x1 = x0 + col_w;
	float y0 = row * row_h;
	float y1 = y0 + row_h;
	
	float x_thickness = OUTLINE_THICKNESS * col_w;
	float y_thickness = OUTLINE_THICKNESS * row_h;
	
	vec4 tex = texture(TEXTURE, UV);
	float tx0 = x0 + x_thickness;
	float tx1 = x1 - x_thickness;
	float ty0 = y0 + y_thickness;
	float ty1 = y1 - y_thickness;
	
	float in_bounds = UV.y > ty0 && UV.y < ty1 && UV.x > tx0 && UV.x < tx1 ? 1.0 : 0.0;
	COLOR = mix(outline_color, tex, in_bounds);
}
