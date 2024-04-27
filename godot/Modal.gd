class_name Modal extends Panel

signal closed()

var ANIMATION_DURATION = 1000

var animation_start
var animation_end
var position_start
var position_end

var is_animating = false
var animating_out = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_animating:
		return
		
	var t = Time.get_ticks_msec()
	
	# Finished transitioning
	if t >= animation_end:
		if animating_out:
			hide()
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
	
func close():
	animate_out()
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
	
func open():
	animate_in()
