extends Control

var tool_config = {
	"tools": [
		{"name": "BandShuffle", "shader_params": []},
		{"name": "Multiplier", "shader_params": []},
		{"name": "ColorCycle", "shader_params": []},
		{"name": "PolkaDots", "shader_params": ["aspect_ratio"]},
		{"name": "SpinShuffle", "shader_params": ["pointer_start"]},
		{"name": "Pixelate", "shader_params": []},
		{"name": "Kaleidoscope", "shader_params": ["pointer"]},
		{"name": "Distort", "shader_params": ["pointer_start", "pointer"]},
		{"name": "Waves", "shader_params": []},
		{"name": "Rainbow", "shader_params": ["pointer"]},
		{"name": "Magnet", "shader_params": ["aspect_ratio", "pointer"]},
		{"name": "HourGlass", "shader_params": []},
		{"name": "Ghost", "shader_params": ["pointer_start", "pointer"]},
		{"name": "DiscoFloor", "shader_params": ["aspect_ratio"]},
		{"name": "Whirlpool", "shader_params": []},
		{"name": "Pattern", "shader_params": ["pointer"]},
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

# Called when the node enters the scene tree for the first time.
func _ready():
	var tools_menu = $ToolsMenu
	tools_menu.init_tool_buttons()
	tools_menu.tool_selected.connect(_on_tool_select)
	_on_tool_select(tool_config["tools"][0]["name"], false)
	
	$SaveFileDialog.connect("file_selected", _on_file_selected)

# Called during every input event.
func _input(event):
	
	# Custom events
	if event.is_action_pressed("ui_save"):
		open_save_dialog()
		
func _on_file_selected(path):
	$Canvas.save_image(path)

func _on_tool_select(tool_name, from_user):
	$ToolsMenu.activate_tool_button(tool_name)
	var tool_found = tool_config["tools"].filter(func(t): return t["name"] == tool_name)
	if tool_found.size() < 1:
		print("Tool name not found: %s" % tool_name)
		return
	var tool = tool_found[0]
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
