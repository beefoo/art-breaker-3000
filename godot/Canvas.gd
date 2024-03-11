# Manages the input/logic for the Canvas

extends Control

var active_mixer
var active_mixer_name
var active_texture

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
				_on_touch_start()
		elif pressing:
				_on_touch_end()
	
	# Touch drag
	elif event is InputEventScreenDrag:
		pass
		
func _on_touch_end():
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
	
func _on_touch_start():
	time = 0.0
	
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
		
	if active_mixer != null:
		active_mixer.set_params({
			"time": time
		})
	
func select_image(image_path):
	active_texture = load("res://art/images/%s" % image_path)
	_on_update_texture()

# Select a mixer by name
func select_mixer(mixer_name):
	# Check if already selected
	if active_mixer_name == mixer_name:
		return
	
	# Deactivate existing mixer
	if active_mixer != null:
		active_mixer.deactivate()
		
	time = 0.0
	active_mixer = get_node(mixer_name)
	active_mixer.activate()
	active_mixer.set_params({
		"speed": 0.4,
		"tex": active_texture,
		"time": time
	})
	
