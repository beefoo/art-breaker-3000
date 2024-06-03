extends Button

signal image_selected(texture, data)

const TRANSITION_DURATION = 500

var random_seed = 0
var item_data
var from_texture
var to_texture
var transition_start
var transition_end

var is_transitioning = false

# Called when the node enters the scene tree for the first time.
func _ready():
	material.set_shader_parameter("aspect", size.aspect())

func _pressed():
	if to_texture == null or item_data == null:
		return
	
	image_selected.emit(to_texture.duplicate(), item_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Show or hide border
	if is_hovered() || has_focus():
		material.set_shader_parameter("border", 0.03)
	else:
		material.set_shader_parameter("border", 0)
	
	if not is_transitioning:
		return
	
	var t = Time.get_ticks_msec()
	
	# Finished transitioning
	if t >= transition_end:
		material.set_shader_parameter("transition", 1.0)
		is_transitioning = false
		return
	
	# Transition between images
	var n = float(t - transition_start) / float(transition_end - transition_start)
	n = (sin((n + 1.5) * PI) + 1.0) / 2.0 # ease in/out
	material.set_shader_parameter("transition", n)

func set_seed(value):
	random_seed = value
	material.set_shader_parameter("seed", random_seed)

func set_item_data(data):
	item_data = data
	
	# Update tooltip
	tooltip_text = "\"%s\" by %s (%s)" % [data["Title"], data["Creator"], data["Date"]]
	
	# Transition to next texture
	if to_texture != null:
		from_texture = to_texture.duplicate()
	to_texture = load("res://art/images/%s.png" % data["Id"])
	if from_texture == null:
		from_texture = to_texture.duplicate()
	
	# Send textures to shader
	material.set_shader_parameter("from_tex", from_texture)
	material.set_shader_parameter("to_tex", to_texture)
	material.set_shader_parameter("from_tex_aspect", from_texture.get_size().aspect())
	material.set_shader_parameter("to_tex_aspect", to_texture.get_size().aspect())
	material.set_shader_parameter("transition", 0.0)
	
	# Start the transition
	transition_start = Time.get_ticks_msec()
	transition_end = transition_start + TRANSITION_DURATION
	is_transitioning = true
