# Manages the input/logic for the Canvas

extends Control

signal texture_updated()

var ANIMATION_DURATION = 1000

var active_mixer
var active_mixer_data
var active_texture
var animation_start
var animation_end
var animation_scale_start
var original_texture
var pointer
var pointer_start
var prev_texture

var aspect_ratio = 1.0
var busy = false
var first_touch = true
var is_active = false
var is_animating = false
var pressing = false
var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_pivot_offset(size / 2.0)
	# select_image(load("res://art/images/sample_mona_lisa.png"))

# Called during every input event.
func _input(event):
	if not is_active:
		return
		
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
		
	# Keyboard/controller enter key is pressed down
	if event.is_action_pressed("ui_accept") and has_focus():
		_on_touch_start(null)
		
	elif event.is_action_released("ui_accept") and has_focus():
		_on_touch_end(null)
	
	# Reset canvas
	if event.is_action_pressed("ui_reset"):
		reset_canvas()
	
	# Undo
	elif event.is_action_pressed("ui_undo"):
		undo()
	
		
func _on_touch_end(event):
	var vt = get_viewport_transform()
	vt.origin = Vector2.ZERO
	busy = true
	pressing = false
	# Wait for current frame to finish drawing
	await RenderingServer.frame_post_draw
	# Get the full viewport image
	var viewport_img = get_viewport().get_texture().get_image()
	# Crop to this canvas and convert back to a texture
	var canvas_region = get_rect() * vt
	var canvas_image = viewport_img.get_region(canvas_region)
	active_texture = ImageTexture.create_from_image(canvas_image)
	# Set this as the new texture for the mixer's shader
	_on_update_texture(false)
	busy = false
	
func _on_touch_move(event):
	if event:
		pointer = get_normalized_position(event.position)
	
func _on_touch_start(event):
	#print("Touch start")
	time = 0.0
	
	if active_texture:
		prev_texture = active_texture.duplicate()
	
	pointer_start = Vector2(0.5, 0.5)
	if event:
		pointer_start = get_normalized_position(event.position)
	pointer = pointer_start
	
	if active_mixer != null:
		active_mixer.set_params({
			"time": time
		})

	if first_touch:
		first_touch = false
		
	pressing = true
		
func _on_update_texture(is_new_image_source):
	time = 0.0
	
	# Resize canvas if new image source
	if is_new_image_source:
		# Resize canvas to fit texture
		var base_rect = get_rect()
		var old_size = get_size()
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
		#print(new_position)
		#print(new_size)
		# Make a copy of the texture for resetting
		original_texture = active_texture.duplicate()
		# Animate between sizes
		set_pivot_offset(new_size / 2.0)
		animation_scale_start = old_size / new_size
		animate()
	
	# Set this as the new texture
	if active_mixer != null and active_mixer_data != null:
		active_mixer.update_size()
		set_shader_params_start()
		
	texture_updated.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animate_step()
	
	if busy:
		return

	if pressing:
		time += delta;
		
	if active_mixer != null and active_mixer_data != null:
		set_shader_params_process()
		
func activate():
	is_active = true
	
func animate():
	animation_start = Time.get_ticks_msec()
	animation_end = animation_start + ANIMATION_DURATION
	is_animating = true
	
func animate_step():
	if not is_animating:
		return
	
	var t = Time.get_ticks_msec()
	
	# Finished animating
	if t >= animation_end:
		set_scale(Vector2(1.0, 1.0))
		is_animating = false
		return
	
	# Animate
	var n = float(t - animation_start) / float(animation_end - animation_start)
	n = ease_elastic(n)
	
	var new_scale = animation_scale_start.lerp(Vector2(1.0, 1.0), n)
	set_scale(new_scale)
	
func deactivate():
	is_active = false
	
func ease_elastic(n):
	if n == 0.0:
		return 0.0
	if n == 1.0:
		return 1.0
	
	var c5 = (2.0 * PI) / 4.5
	var h = 20.0
	if n < 0.5:
		return -(pow(2.0, h * n - 10.0) * sin((h * n - 11.125) * c5)) / 2.0
		
	return (pow(2.0, -h * n + 10.0) * sin((h * n - 11.125) * c5)) / 2.0 + 1.0

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
	
func reset_canvas():	
	if original_texture == null:
		return
		
	active_texture = original_texture
	_on_update_texture(false)
	
func save_image(image_path):
	if active_texture == null:
		return
		
	var active_image = active_texture.get_image()
	active_image.save_png(image_path)
	
func select_image(image_texture):
	active_texture = image_texture
	_on_update_texture(true)

# Select a mixer by name
func select_mixer(tool, from_user):
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
	set_shader_params_start()
	
	# Grab focus if triggered by user
	if from_user:
		grab_focus()

func set_original_image(texture):
	original_texture = texture.duplicate()

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


func undo():
	if active_texture == null || prev_texture == null:
		return
	var temp_texture = active_texture.duplicate()
	active_texture = prev_texture
	prev_texture = temp_texture
	_on_update_texture(false)
