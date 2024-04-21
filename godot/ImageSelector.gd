extends Panel

var button_count = 0
var collection_data = []
var collection_data_file = "data/collection.json"
var collection_size = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	button_count = $ImageButtons.get_child_count()
	# Load collection data
	load_collection_data(collection_data_file)
	# Show random set
	show_random_set()
	# Load listeners
	$ActionButtons/RandomizeButton.pressed.connect(show_random_set)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Load collection data from file
func load_collection_data(data_file):
	var json_string = FileAccess.get_file_as_string(data_file)
	collection_data = JSON.parse_string(json_string)
	collection_size = collection_data.size()
	print("Loaded %s collection items" % collection_size)

# Assign a button an item (image, text, etc)
func set_button_data(button_index, item_data):
	var button = get_node("ImageButtons/SelectImageButton%s" % button_index)
	button.set_item_data(item_data)

# Show a random set of images to select from
func show_random_set():
	collection_data.shuffle() # Randomize the order
	
	for i in range(button_count):
		set_button_data(i + 1, collection_data[i])
