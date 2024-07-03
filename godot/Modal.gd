class_name Modal extends Panel

signal closed()

var ANIMATION_DURATION = 1000
var DELAY_AUDIO = 0.25

var animation_start
var animation_end
var position_start
var position_end

var is_animating = false
var animating_out = false

@onready var audio_player = $AudioStreamPlayer

func _on_close():
	pass

func _on_open():
	pass
	
func _on_link_clicked(url):
	OS.shell_open(url)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_animating:
		return
		
	var t = Time.get_ticks_msec()
	
	# Finished transitioning
	if t > animation_end:
		set_position (Vector2(0.0, position_end))
		if animating_out:
			hide()
			_on_close()
		else:
			_on_open()
		is_animating = false
		return
		
	if not visible:
		show()
	
	# Transition between images
	var n = float(t - animation_start) / float(animation_end - animation_start)
	n = ease_bounce(n)
	
	var new_y = lerpf(position_start, position_end, n)
	set_position (Vector2(0.0, new_y))

func animate_in():
	# Start the transition
	animation_start = Time.get_ticks_msec()
	animation_end = animation_start + ANIMATION_DURATION
	position_start = -size.y
	position_end = 0
	is_animating = true
	animating_out = false
	
func animate_out():
	# Start the transition
	animation_start = Time.get_ticks_msec()
	animation_end = animation_start + ANIMATION_DURATION
	position_start = 0
	position_end = size.y
	is_animating = true
	animating_out = true
	
func close(with_sound=true):
	animate_out()
	if with_sound:
		play_sound()
	closed.emit()

func ease_bounce(n):
	var n1 = 7.5625;
	var d1 = 2.75;

	if n < (1.0 / d1):
		return n1 * n * n
	elif n < (2.0 / d1):
		var n2 = n - 1.5 / d1
		return n1 * n2 * n2 + 0.75
	elif n < (2.5 / d1):
		var n2 = n - 2.25 / d1
		return n1 * n2 * n2 + 0.9375
	else:
		var n2 = n - 2.65 / d1
		return n1 * n2 * n2 + 0.984375
	
func open(with_sound=true):
	animate_in()
	if with_sound:
		play_sound()
	
func play_sound():
	await get_tree().create_timer(DELAY_AUDIO).timeout
	audio_player.play(0.0)
