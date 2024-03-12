# Manages the input/logic for the Canvas

extends Control

var active_mixer
var active_mixer_data
var active_texture

var pointer_start
var pointer

var busy = false
var first_touch = true
var pressing = false
var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
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
	_on_update_texture()
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
		
func _on_update_texture():
	time = 0.0
	# Set this as the new texture
	if active_mixer != null:
		active_mixer.set_params({
			"tex": active_texture,
			"time": time
		})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if busy:
		return

	if pressing:
		time += delta;
		
	if active_mixer != null and active_mixer_data != null:
		var shader_params = active_mixer_data["shader_params"]
		var shader_values = {}
		
		shader_values["time"] = time;
		if (shader_params.has("pointer_start")):
			shader_values["pointer_start"] = pointer_start;
		if (shader_params.has("pointer")):
			shader_values["pointer"] = pointer;
		
		active_mixer.set_params(shader_values)

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
	_on_update_texture()

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
	
