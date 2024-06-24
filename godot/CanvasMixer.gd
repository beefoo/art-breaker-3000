# The direct child of Canvas, that "mixes" the current texture

extends Control

var audio_player
var audio_bus_indices = {}
var audio_effects = {}
var has_audio = false
var is_active = true

# Custom options to send into shaders shaders
@export var shader_aspect_ratio = false # the image's aspect ratio
@export var shader_pointer = false # the user's current pointer position
@export var shader_pointer_start = false # the user's starting pointer position

# Called when the node enters the scene tree for the first time.
func _ready():
	# If not visible, assume disabled
	if not visible:
		deactivate()
		
	audio_player = get_node_or_null("AudioStreamPlayer")
	has_audio = audio_player != null
	
	load_audio_effect("Pitch")
	load_audio_effect("Delay")
	load_audio_effect("Distortion")
	load_audio_effect("Filter")
	load_audio_bus("Volume")

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

	if audio_player.effect_mode == null:
		return
	
	var effect_prop = audio_player.effect_property
	var effect_dur = audio_player.effect_dur
	var effect_min = audio_player.effect_min
	var effect_max = audio_player.effect_max

	# Speed up or slow down sound over time
	if audio_player.effect_mode == "ease_in":
		var t = smoothstep(0.0, effect_dur, params["time"])
		var new_scale = lerp(effect_min, effect_max, t)
		set_audio_effect_value(effect_prop, new_scale)

	# Change audio pitch based on distance from original pointer
	elif audio_player.effect_mode == "pointer":
		var pointer = params["pointer"]
		var pointer_start = params["pointer_start"]
		if pointer == null or pointer_start == null:
			return
		var d = clamp(pointer_start.distance_to(pointer) * 2.0, 0.0, 1.0)
		var new_scale = lerp(effect_min, effect_max, d)
		set_audio_effect_value(effect_prop, new_scale)

	# Modulate between min/max pitch
	elif audio_player.effect_mode == "wave":
		var t = (sin(params["time"] * (PI / effect_dur)) + 1.0) / 2.0
		var new_scale = lerp(effect_min, effect_max, t)
		set_audio_effect_value(effect_prop, new_scale)
		
	# Change pitch based on velocity of pointer
	elif audio_player.effect_mode == "velocity":
		var t = smoothstep(300.0, 3000.0, params["pointer_velocity"].length())
		var new_scale = lerp(effect_min, effect_max, t)
		set_audio_effect_value(effect_prop, new_scale)

func audio_start():
	if not has_audio:
		return
	
	if audio_player.effect_min > 0.0:
		set_audio_effect_value(audio_player.effect_property, audio_player.effect_min)
	
	audio_player.play(0.0)

# Hide and disable processing
func deactivate():
	is_active = false;
	set_process(false)
	hide()

func load_audio_bus(bus_name):
	var bus_index = AudioServer.get_bus_index(bus_name)
	audio_bus_indices[bus_name] = bus_index

func load_audio_effect(effect_name):
	var effect_index = AudioServer.get_bus_index(effect_name)
	audio_effects[effect_name] = AudioServer.get_bus_effect(effect_index, 0)
	
func set_audio_effect_value(effect_name, value):
	if effect_name == "Scale":
		audio_player.set_pitch_scale(value)
	elif effect_name == "Pitch":
		audio_effects["Pitch"].set_pitch_scale(value)
	elif effect_name == "Delay":
		audio_effects["Delay"].set_feedback_delay_ms(value)
	elif effect_name == "Distortion":
		audio_effects["Distortion"].set_drive(value)
	elif effect_name == "Filter":
		audio_effects["Filter"].set_cutoff(value)
	elif effect_name == "Volume":
		var bus_index = audio_bus_indices["Volume"]
		AudioServer.set_bus_volume_db(bus_index, value)

func set_params(params):
	for property in params:
		var value = params[property]
		material.set_shader_parameter(property, value)
		
func update_size():
	set_size(get_parent().size)
	set_position(Vector2.ZERO)
	queue_redraw()
