# Manages the input/logic for the Canvas

extends Control

var active_mixer
var active_mixer_data
var active_texture
var base_rect
var pointer
var pointer_start

var aspect_ratio = 1.0
var busy = false
var first_touch = true
var pressing = false
var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	base_rect = get_rect()
	select_image("loc-2010715115.png")

# Called during every input event.
func _input(event):
	# Keep track of start and stop touch/press
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT or event is InputEventScreenTouch:
		var is_inside_canvas = get_rect().has_point(event.position)
			
		if event.pressed:
			if is_inside_canvas:
				_on_touch_start(event)
		elif pressing:
				_on_touch_end(event)
				
	# Touch drag
	elif event is InputEventScreenDrag or pressing and event is InputEventMouseMotion:
		_on_touch_move(event)
		pass
		
func _on_touch_end(event):
	busy = true
	pressing = false
	# Wait for current frame to finish drawing
	await RenderingServer.frame_post_draw
	# Get the full viewport image
	var viewport_img = get_viewport().get_texture().get_image()
	# Crop to this canvas and convert back to a texture
	var canvas_region = get_rect()
	var canvas_image = viewport_img.get_region(canvas_region)
	active_texture = ImageTexture.create_from_image(canvas_image)
	# Set this as the new texture for the mixer's shader
	_on_update_texture(false)
	busy = false
	
func _on_touch_move(event):
	pointer = get_normalized_position(event.position)
	
func _on_touch_start(event):
	time = 0.0
	
	pointer_start = get_normalized_position(event.position)
	pointer = pointer_start
	
	if active_mixer != null:
		active_mixer.set_params({
			"time": time
		})

	if first_touch:
		first_touch = false
		
	pressing = true
		
func _on_update_texture(needsResize):
	time = 0.0
	
	if needsResize:
		# Resize canvas to fit texture
		var tex_size = active_texture.get_size()
		var new_size = Vector2.ZERO
		var new_position = Vector2.ZERO
		# Image is more narrow than canvas
		if tex_size.aspect() < base_rect.size.aspect():
			var scale_tex = 1.0 * base_rect.size.y / tex_size.y
			var new_width = roundi(tex_size.x * scale_tex)
			var new_x = roundi((base_rect.size.x - new_width) * 0.5) + base_rect.position.x
			new_size = Vector2(new_width, base_rect.size.y)
			new_position = Vector2(new_x, base_rect.position.y)
		# Image is more wide than canvas
		else:
			var scale_tex = 1.0 * base_rect.size.x / tex_size.x
			var new_height = roundi(tex_size.y * scale_tex)
			var new_y = roundi((base_rect.size.y - new_height) * 0.5) + base_rect.position.y
			new_size = Vector2(base_rect.size.x, new_height)
			new_position = Vector2(base_rect.position.x, new_y)
		aspect_ratio = tex_size.aspect()
		set_position(new_position)
		set_size(new_size)
	
	# Set this as the new texture
	if active_mixer != null and active_mixer_data != null:
		active_mixer.update_size()
		set_shader_params_start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if busy:
		return

	if pressing:
		time += delta;
		
	if active_mixer != null and active_mixer_data != null:
		set_shader_params_process()

func normalize_value(value, min_value, max_value):
	var n = 0.0
	
	if (max_value - min_value) > 0:
		n = 1.0 * (value - min_value) / (max_value - min_value)
		
	return n
	
func get_normalized_position(position):
	var canvas_rect = get_rect()
	var n_position = Vector2(
		normalize_value(position.x, canvas_rect.position.x, canvas_rect.position.x + canvas_rect.size.x),
		normalize_value(position.y, canvas_rect.position.y, canvas_rect.position.y + canvas_rect.size.y)
	)
	n_position = n_position.clamp(Vector2.ZERO, Vector2.ONE)
	return n_position	
	
func select_image(image_path):
	active_texture = load("res://art/images/%s" % image_path)
	_on_update_texture(true)

# Select a mixer by name
func select_mixer(tool):
	var mixer_data = tool.duplicate()
	# Check if already selected
	if active_mixer_data && active_mixer_data["name"] == mixer_data["name"]:
		return
	
	# Deactivate existing mixer
	if active_mixer != null:
		active_mixer.deactivate()
		
	time = 0.0
	active_mixer = get_node(mixer_data["name"])
	active_mixer_data = mixer_data
	active_mixer.activate()
	active_mixer.set_params({
		"tex": active_texture,
		"time": time
	})

# Set shader parameters at every frame
func set_shader_params_process():
	var shader_params = active_mixer_data["shader_params"]
	var shader_values = {}
	
	shader_values["time"] = time;
	if (shader_params.has("pointer_start")):
		shader_values["pointer_start"] = pointer_start;
	if (shader_params.has("pointer")):
		shader_values["pointer"] = pointer;
	
	active_mixer.set_params(shader_values)

# Set shader parameters when texture updates or mixer is selected
func set_shader_params_start():
	var shader_params = active_mixer_data["shader_params"]
	var shader_values = {
		"tex": active_texture,
		"time": time
	}
	
	if (shader_params.has("aspect_ratio")):
		shader_values["aspect_ratio"] = aspect_ratio;
		
	active_mixer.set_params(shader_values)
	
