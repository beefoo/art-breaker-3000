extends Control

var active_mixer
var active_texture

var first_touch = true
var mixer_selected = false
var pressing = false
var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	select_image("loc-2010715115.png")

# Called during every input event.
func _input(event):
	# Keep track of start and stop touch/press
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT or event is InputEventScreenTouch:
		pressing = event.pressed
		if pressing:
			_on_touch_start()
		else:
			_on_touch_end()
	
	# Touch drag
	elif event is InputEventScreenDrag:
		pass
		
func _on_touch_end():
	pass
	
func _on_touch_start():
	if first_touch:
		first_touch = false
		select_mixer("BandShuffle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pressing:
		time += delta;
		
	if active_mixer != null:
		active_mixer.set_params({
			"time": time
		})
	
func select_image(image_path):
	active_texture = load("res://art/%s" % image_path)

func select_mixer(mixer_name):
	active_mixer = get_node(mixer_name)
	active_mixer.activate()
	active_mixer.set_params({
		"speed": 4.0,
		"tex": active_texture,
		"time": 0.0
	})
	time = 0.0
	mixer_selected = true
