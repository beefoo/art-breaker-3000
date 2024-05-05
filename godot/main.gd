extends Control

var tool_config = {
	"tools": [
		{"name": "BandShuffle", "shader_params": []},
		{"name": "Multiplier", "shader_params": []},
		{"name": "ColorCycle", "shader_params": []},
		{"name": "PolkaDots", "shader_params": ["aspect_ratio"]},
		{"name": "SpinShuffle", "shader_params": ["aspect_ratio", "pointer_start"]},
		{"name": "Pixelate", "shader_params": []},
		{"name": "Kaleidoscope", "shader_params": ["pointer"]},
		{"name": "Distort", "shader_params": ["pointer_start", "pointer"]},
		{"name": "Waves", "shader_params": []},
		{"name": "Rainbow", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "Magnet", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "HourGlass", "shader_params": []},
		{"name": "Ghost", "shader_params": ["pointer_start", "pointer"]},
		{"name": "DiscoFloor", "shader_params": ["aspect_ratio"]},
		{"name": "Whirlpool", "shader_params": ["aspect_ratio"]},
		{"name": "Pattern", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "Weave", "shader_params": []},
		{"name": "Drain", "shader_params": []},
		{"name": "Reflect", "shader_params": []},
		{"name": "Bend", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "Checkerboard", "shader_params": ["aspect_ratio"]},
		{"name": "Smudge", "shader_params": ["pointer_start", "pointer"]},
		{"name": "Swirl", "shader_params": []},
		{"name": "Dissolve", "shader_params": []},
	]
}

var auto_save_image_path = "user://autosave.png"
var auto_save_data_path = "user://autosave.json"
var first_process = true
var image_selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load tools
	var tools_menu = $ToolsMenu
	tools_menu.init_tool_buttons()
	tools_menu.tool_selected.connect(_on_tool_selected)
	_on_tool_selected(tool_config["tools"][0]["name"], false)
	
	# Load listeners
	$SaveFileDialog.file_selected.connect(_on_save_file_selected)
	
	$ImageSelector.image_selected.connect(_on_image_selected)
	$ItemDetail.closed.connect(_on_dialog_close)
	$CanvasContainer/Canvas.texture_updated.connect(_on_texture_updated)
	get_viewport().size_changed.connect(_on_resize)

# Called during every input event.
func _input(event):
	
	# Custom events
	if event.is_action_pressed("ui_cancel"):
		_on_cancel()
		
	elif event.is_action_pressed("ui_info"):
		open_info_dialog()
		
	elif event.is_action_pressed("ui_new"):
		open_new_dialog()
		
	elif event.is_action_pressed("ui_quit"):
		quit()
		
	elif event.is_action_pressed("ui_random"):
		select_random_image()
		
	elif event.is_action_pressed("ui_save"):
		open_save_dialog()
		
func _on_cancel():
	if $ImageSelector.visible && image_selected:
		$ImageSelector.close()
		
	elif $ItemDetail.visible:
		$ItemDetail.close()

func _on_dialog_close():
	$CanvasContainer/Canvas.activate()
	
func _on_image_selected(texture, data):
	image_selected = true
	$CanvasContainer/Canvas.select_image(texture)
	$CanvasContainer/Canvas.activate()
	$ItemDetail.set_item(texture, data)
	auto_save_data(data)

func _on_resize():
	$CanvasContainer/Canvas._on_resize()

func _on_save_file_selected(path):
	$CanvasContainer/Canvas.save_image(path)

func _on_texture_updated():
	auto_save_image()

func _on_tool_selected(tool_name, from_user):
	$ToolsMenu.activate_tool_button(tool_name)
	var tool_found = tool_config["tools"].filter(func(t): return t["name"] == tool_name)
	if tool_found.size() < 1:
		print("Tool name not found: %s" % tool_name)
		return
	var tool = tool_found[0]
	$CanvasContainer/Canvas.select_mixer(tool, from_user)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if first_process:
		first_process = false
		auto_load()
	
func auto_load():
	if not FileAccess.file_exists(auto_save_image_path) or not FileAccess.file_exists(auto_save_data_path):
		return
	
	var image = Image.load_from_file(auto_save_image_path)
	var texture = ImageTexture.create_from_image(image)
	var json_string = FileAccess.get_file_as_string(auto_save_data_path)
	var data = JSON.parse_string(json_string)
	
	var item_texture
	# This is a user-imported image
	if data.has("Path"):
		image = Image.load_from_file(data["Path"])
		item_texture = ImageTexture.create_from_image(image)
	# Otherwise one of the collection images
	else:
		item_texture = load("res://art/images/%s.png" % data["Id"])
	
	image_selected = true
	$CanvasContainer/Canvas.select_image(texture)
	$CanvasContainer/Canvas.set_original_image(item_texture)
	$CanvasContainer/Canvas.activate()
	$ItemDetail.set_item(item_texture, data)
	$ImageSelector.close()

func auto_save_data(data):
	var json_string = JSON.stringify(data)
	var file = FileAccess.open(auto_save_data_path, FileAccess.WRITE)
	file.store_string(json_string)

func auto_save_image():
	$CanvasContainer/Canvas.save_image(auto_save_image_path)

func open_info_dialog():
	$ItemDetail.open()
	$CanvasContainer/Canvas.deactivate()
	
func open_new_dialog():
	$ImageSelector.open()
	$CanvasContainer/Canvas.deactivate()
	
func open_save_dialog():
	#var timestamp = Time.get_datetime_string_from_system().replace("T", "-").replace(":", "")
	#
	## Try to use native file selector first
	#var on_file_selected = func(status, selected_paths, selected_filter_index):
		#if selected_paths.size() > 0:
			#_on_save_file_selected(selected_paths[0])
	#var error = DisplayServer.file_dialog_show("Save image", "", "art_breaker_%s.png" % timestamp, false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, PackedStringArray(["*.png"]), on_file_selected)
	#
	## Otherwise, use the Godot file dialog
	#if error != OK:
		#$SaveFileDialog.popup_centered()
	$SaveFileDialog.popup_centered()
	
func quit():
	get_tree().quit()
		
func select_random_image():
	$ImageSelector.select_random_image()
