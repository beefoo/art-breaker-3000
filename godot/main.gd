extends Control

var tool_config = {
	"tools": [
		{"name": "BandShuffle", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "Multiplier", "icon": "art/icons/copy.svg", "shader_params": []},
		{"name": "ColorCycle", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "PolkaDots", "icon": "art/icons/copy.svg", "shader_params": ["aspect_ratio"]},
		{"name": "SpinShuffle", "icon": "art/icons/shuffle.svg", "shader_params": ["pointer_start"]},
		{"name": "Pixelate", "icon": "art/icons/copy.svg", "shader_params": []},
		{"name": "Kaleidoscope", "icon": "art/icons/shuffle.svg", "shader_params": ["pointer"]},
		{"name": "Distort", "icon": "art/icons/copy.svg", "shader_params": ["pointer_start", "pointer"]},
		{"name": "Waves", "icon": "art/icons/copy.svg", "shader_params": []},
		{"name": "Rainbow", "icon": "art/icons/shuffle.svg", "shader_params": ["pointer"]},
		{"name": "Magnet", "icon": "art/icons/copy.svg", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "HourGlass", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "Ghost", "icon": "art/icons/copy.svg", "shader_params": ["pointer_start", "pointer"]},
		{"name": "DiscoFloor", "icon": "art/icons/shuffle.svg", "shader_params": ["aspect_ratio"]},
		{"name": "Whirlpool", "icon": "art/icons/copy.svg", "shader_params": []},
		{"name": "Pattern", "icon": "art/icons/shuffle.svg", "shader_params": ["pointer"]},
		{"name": "Weave", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "Drain", "icon": "art/icons/copy.svg", "shader_params": []},
		{"name": "Reflect", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "Bend", "icon": "art/icons/copy.svg", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "Checkerboard", "icon": "art/icons/shuffle.svg", "shader_params": ["aspect_ratio"]},
		{"name": "Smudge", "icon": "art/icons/copy.svg", "shader_params": ["pointer_start", "pointer"]},
		{"name": "Swirl", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "Dissolve", "icon": "art/icons/copy.svg", "shader_params": []},
	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var tools_menu = $ToolsMenu
	tools_menu.create_tool_buttons(tool_config["tools"])
	tools_menu.tool_selected.connect(_on_tool_select)
	_on_tool_select(tool_config["tools"][0], false)
	
	$SaveFileDialog.connect("file_selected", _on_file_selected)

# Called during every input event.
func _input(event):
	
	# Custom events
	if event.is_action_pressed("ui_save"):
		open_save_dialog()
		
func _on_file_selected(path):
	$Canvas.save_image(path)

func _on_tool_select(tool, from_user):
	$Canvas.select_mixer(tool, from_user)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func open_save_dialog():
	var timestamp = Time.get_datetime_string_from_system().replace("T", "-").replace(":", "")
	
	# Try to use native file selector first
	var on_file_selected = func(status, selected_paths, selected_filter_index):
		if selected_paths.size() > 0:
			_on_file_selected(selected_paths[0])
	var error = DisplayServer.file_dialog_show("Save image", "", "art_breaker_%s.png" % timestamp, false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, PackedStringArray(["*.png"]), on_file_selected)
	
	# Otherwise, use the Godot file dialog
	if error != OK:
		$SaveFileDialog.popup_centered()
