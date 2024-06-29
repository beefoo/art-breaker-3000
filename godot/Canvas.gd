# Manages the input/logic for the Canvas

extends Control

signal texture_updated()

var ANIMATION_DURATION = 1000

var active_mixer
var active_texture
var active_audio_player
var animation_start
var animation_end
var animation_scale_start
var original_texture
var pointer
var pointer_start
var pointer_velocity = Vector2.ZERO
var prev_texture

var aspect_ratio = 1.0
var busy = false
var first_touch = true
var is_active = false
var is_animating = false
var pressing = false
var time = 0.0

@onready var audio_player = $AudioStreamPlayer

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
		var is_inside_canvas = get_absolute_rect().has_point(event.position)
			
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

func _on_resize():
	resize_and_center()
		
func _on_touch_end(_event):
	if active_mixer != null:
		active_mixer.audio_end()
	var vt = get_viewport_transform()
	vt.origin = Vector2.ZERO
	busy = true
	pressing = false
	pointer_velocity = Vector2.ZERO
	# Wait for current frame to finish drawing
	await RenderingServer.frame_post_draw
	# Get the full viewport image
	var viewport_img = get_viewport().get_texture().get_image()
	# Crop to this canvas and convert back to a texture
	var canvas_region = get_absolute_rect() * vt
	canvas_region.position = canvas_region.position.round()
	canvas_region.size = canvas_region.size.round()
	var canvas_image = viewport_img.get_region(canvas_region)
	active_texture = ImageTexture.create_from_image(canvas_image)
	# Set this as the new texture for the mixer's shader
	_on_update_texture(false)
	busy = false
	
func _on_touch_move(event):
	if event:
		pointer = get_normalized_position(event.position)
		pointer_velocity = event.velocity
	
func _on_touch_start(event):
	#print("Touch start")
	time = 0.0
	
	if active_texture:
		prev_texture = active_texture.duplicate()
	
	pointer_start = Vector2(0.5, 0.5)
	if event:
		pointer_start = get_normalized_position(event.position)
	pointer = pointer_start
	pointer_velocity = Vector2.ZERO
	
	if active_mixer != null:
		active_mixer.set_params({
			"time": time
		})
		active_mixer.audio_start()

	if first_touch:
		first_touch = false
		
	pressing = true
		
func _on_update_texture(is_new_image_source):
	time = 0.0
	
	# Resize canvas if new image source
	if is_new_image_source:
		# Resize canvas to fit texture
		var old_size = get_size()
		var new_rect = resize_and_center()
		var new_size = new_rect.size
		var tex_size = active_texture.get_size()
		aspect_ratio = tex_size.aspect()
		# Make a copy of the texture for resetting
		original_texture = active_texture.duplicate()
		# Animate between sizes
		animation_scale_start = old_size / new_size
		animate()
	
	# Set this as the new texture
	if active_mixer != null:
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
		
	if active_mixer != null:
		set_shader_params_process()
		set_audio_params()
		
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
	
func get_absolute_rect():
	var parent_position = get_parent().get_position()
	var rect = get_rect()
	rect.position += parent_position
	return rect
	
func get_normalized_position(pos):
	var canvas_rect = get_absolute_rect()
	var n_position = Vector2(
		normalize_value(pos.x, canvas_rect.position.x, canvas_rect.position.x + canvas_rect.size.x),
		normalize_value(pos.y, canvas_rect.position.y, canvas_rect.position.y + canvas_rect.size.y)
	)
	n_position = n_position.clamp(Vector2.ZERO, Vector2.ONE)
	return n_position

func reset_canvas():	
	if original_texture == null:
		return
	
	audio_player.play(0.0)
	active_texture = original_texture
	_on_update_texture(false)
	
func resize_and_center():
	if active_texture == null:
		return
		
	var base_rect = get_parent().get_rect()
	var tex_size = active_texture.get_size()
	var new_size = Vector2.ZERO
	var new_position = Vector2.ZERO
	# Image is more narrow than canvas
	if tex_size.aspect() < base_rect.size.aspect():
		var scale_tex = 1.0 * base_rect.size.y / tex_size.y
		var new_width = roundi(tex_size.x * scale_tex)
		new_size = Vector2(new_width, base_rect.size.y)
		var new_x = roundi((base_rect.size.x - new_width) * 0.5)
		new_position.x = new_x
	# Image is more wide than canvas
	else:
		var scale_tex = 1.0 * base_rect.size.x / tex_size.x
		var new_height = roundi(tex_size.y * scale_tex)
		new_size = Vector2(base_rect.size.x, new_height)
		var new_y = roundi((base_rect.size.y - new_height) * 0.5)
		new_position.y = new_y
	set_pivot_offset(new_size / 2.0)
	set_position(new_position)
	set_size(new_size)
	return Rect2(new_position, new_size)
	
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
	# Check if already selected
	if active_mixer != null && active_mixer.get_name() == tool.get_name():
		return
	
	# Deactivate existing mixer
	if active_mixer != null:
		active_mixer.deactivate()
		
	time = 0.0
	active_mixer = tool
	active_mixer.activate()
	set_shader_params_start()
	
	# Grab focus if triggered by user
	if from_user:
		grab_focus()
	
func set_audio_params():
	active_mixer.audio_progress({
		"time": time,
		"pointer_start": pointer_start,
		"pointer": pointer,
		"pointer_velocity": pointer_velocity
	})

func set_original_image(texture):
	original_texture = texture.duplicate()

# Set shader parameters at every frame
func set_shader_params_process():
	if active_mixer == null:
		return
		
	var shader_values = {}
	
	shader_values["time"] = time;
	if (active_mixer.shader_pointer_start):
		shader_values["pointer_start"] = pointer_start;
	if (active_mixer.shader_pointer):
		shader_values["pointer"] = pointer;
	
	active_mixer.set_params(shader_values)

# Set shader parameters when texture updates or mixer is selected
func set_shader_params_start():
	if active_mixer == null:
		return
		
	var shader_values = {
		"tex": active_texture,
		"time": time
	}
	
	if (active_mixer.shader_aspect_ratio):
		shader_values["aspect_ratio"] = aspect_ratio;
		
	active_mixer.set_params(shader_values)


func undo():
	if active_texture == null || prev_texture == null:
		return
	audio_player.play(0.0)
	var temp_texture = active_texture.duplicate()
	active_texture = prev_texture
	prev_texture = temp_texture
	_on_update_texture(false)
