extends Modal

signal image_selected(texture, data)

var allow_cancel = true
var button_count = 0
var collection_data = []
var collection_data_file = "data/collection.json"
var collection_size = 0

@onready var button_audio_player = $ButtonAudioPlayer
@onready var transition_audio_player = $TransitionAudioPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	button_count = $ImageButtons.get_child_count()
	# Load collection data
	load_collection_data(collection_data_file)
	# Show random set
	show_random_set(true)
	# Load listeners
	$ActionButtons/RandomizeButton.pressed.connect(show_random_set)
	for i in range(button_count):
		var button_index = i + 1
		var button = get_node("ImageButtons/SelectImageButton%s" % button_index)
		button.set_seed(float(i + 1) / float(button_count))
		button.image_selected.connect(_on_image_selected)
	$ActionButtons/ImportButton.pressed.connect(open_import_dialog)
	$ImportFileDialog.file_selected.connect(_on_import_image_selected)
	$ActionButtons/CancelButton.pressed.connect(close)

func _on_close():
	allow_cancel = true

func _on_image_selected(texture, data):
	image_selected.emit(texture, data)
	close()
	
func _on_import_image_selected(path):
	var data = {
		"Title": "Custom imported image",
		"Path": path
	}
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	_on_image_selected(texture, data)
	
func _on_open():
	if allow_cancel:
		$ActionButtons/CancelButton.show()
	focus_on_first_control()

func focus_on_first_control():
	$ActionButtons/RandomizeButton.grab_focus()

# Load collection data from file
func load_collection_data(data_file):
	var json_string = FileAccess.get_file_as_string(data_file)
	collection_data = JSON.parse_string(json_string)
	collection_size = collection_data.size()
	print("Loaded %s collection items" % collection_size)
	
func open_import_dialog():
	$ImportFileDialog.popup_centered()
	
func select_random_image():
	transition_audio_player.play(0.0)
	var random_item = collection_data.pick_random()
	var texture = load("res://art/images/%s.png" % random_item["Id"])
	image_selected.emit(texture, random_item)

# Assign a button an item (image, text, etc)
func set_button_data(button_index, item_data):
	var button = get_node("ImageButtons/SelectImageButton%s" % button_index)
	button.set_item_data(item_data)

# Show a random set of images to select from
func show_random_set(initial = false):
	collection_data.shuffle() # Randomize the order
	
	for i in range(button_count):
		set_button_data(i + 1, collection_data[i])
		
	if not initial:
		button_audio_player.play(0.0)
