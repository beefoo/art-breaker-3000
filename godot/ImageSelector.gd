extends Panel

signal image_selected(texture, data)

var ANIMATION_DURATION = 1000

var animation_start
var animation_end
var position_start
var position_end

var is_animating = false
var animating_out = false
var button_count = 0
var collection_data = []
var collection_data_file = "data/collection.json"
var collection_size = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the pivot to the center
	set_pivot_offset(size * 0.5)
	button_count = $ImageButtons.get_child_count()
	# Load collection data
	load_collection_data(collection_data_file)
	# Show random set
	show_random_set()
	# Load listeners
	$ActionButtons/RandomizeButton.pressed.connect(show_random_set)
	for i in range(button_count):
		var button_index = i + 1
		var button = get_node("ImageButtons/SelectImageButton%s" % button_index)
		button.image_selected.connect(_on_image_selected)

func _on_image_selected(texture, data):
	image_selected.emit(texture, data)
	animate_out()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_animating:
		return
		
	var t = Time.get_ticks_msec()
	
	# Finished transitioning
	if t >= animation_end:
		if animating_out:
			hide()
		is_animating = false
		return
		
	if !visible:
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
	
	var c5 = (2.0 * PI) / 4.5;
	var h = 20.0
	if n < 0.5:
		return -(pow(2.0, h * n - 10.0) * sin((h * n - 11.125) * c5)) / 2.0
		
	return (pow(2.0, -h * n + 10.0) * sin((h * n - 11.125) * c5)) / 2.0 + 1.0;

# Load collection data from file
func load_collection_data(data_file):
	var json_string = FileAccess.get_file_as_string(data_file)
	collection_data = JSON.parse_string(json_string)
	collection_size = collection_data.size()
	print("Loaded %s collection items" % collection_size)
	
func select_random_image():
	var random_item = collection_data.pick_random()
	var texture = load("res://art/images/%s.png" % random_item["Id"])
	image_selected.emit(texture, random_item)

# Assign a button an item (image, text, etc)
func set_button_data(button_index, item_data):
	var button = get_node("ImageButtons/SelectImageButton%s" % button_index)
	button.set_item_data(item_data)

# Show a random set of images to select from
func show_random_set():
	collection_data.shuffle() # Randomize the order
	
	for i in range(button_count):
		set_button_data(i + 1, collection_data[i])
