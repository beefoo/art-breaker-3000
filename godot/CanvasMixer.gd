# The direct child of Canvas, that "mixes" the current texture

extends Control

var audio_player
var has_audio = false
var is_active = true
var audio_options = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# If not visible, assume disabled
	if not visible:
		deactivate()
		
	audio_player = get_node_or_null("AudioStreamPlayer")
	has_audio = audio_player != null

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.0))

# Show and enable processing
func activate():
	is_active = true
	update_size()
	set_process(true)
	show()

func audio_end():
	if not has_audio:
		return
		
	audio_player.stop()
		
func audio_progress(params):
	if not has_audio:
		return
		
	if audio_options["mode"] == "accelerate":
		var time = params["time"]
		var new_scale = pow(time * audio_options["base_speed"], audio_options["acceleration"])
		new_scale = clamp(new_scale, audio_options["min_pitch_scale"], audio_options["max_pitch_scale"])
		audio_player.set_pitch_scale(new_scale)

func audio_start():
	if not has_audio:
		return
		
	audio_player.play(0.0)

# Hide and disable processing
func deactivate():
	is_active = false;
	set_process(false)
	hide()

func set_params(params):
	for property in params:
		var value = params[property]
		material.set_shader_parameter(property, value)

func set_audio_options(options):
	audio_options = options
		
func update_size():
	set_size(get_parent().size)
	set_position(Vector2.ZERO)
	queue_redraw()
