extends VBoxContainer

var ANIMATION_DURATION = 500

var animation_start
var animation_end
var width

var is_animating = false
var animating_out = false

func _ready():
	width = size.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_animating:
		return
		
	var t = Time.get_ticks_msec()
	
	# Finished transitioning
	if t > animation_end:
		set_scale(Vector2(1.0, 1.0))
		set_position(Vector2(0.0, 0.0))
		if animating_out:
			hide()
		is_animating = false
		return
		
	if not visible:
		show()
	
	# Transition
	var n = float(t - animation_start) / float(animation_end - animation_start)
	if animating_out:
		n = 1.0 - n
	n = smoothstep(0.0, 1.0, n)
	
	set_scale(Vector2(n, 1.0))
	
	var new_x = width - width * n if not animating_out else 0.0
	set_position(Vector2(new_x, 0.0))
	#var new_y = lerpf(position_start, position_end, n)
	#set_position (Vector2(0.0, new_y))

func animate_in():
	# Start the transition
	animation_start = Time.get_ticks_msec()
	animation_end = animation_start + ANIMATION_DURATION
	is_animating = true
	animating_out = false
	
func animate_out():
	if not visible:
		return
	# Start the transition
	animation_start = Time.get_ticks_msec()
	animation_end = animation_start + ANIMATION_DURATION
	is_animating = true
	animating_out = true
