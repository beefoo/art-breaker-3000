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
	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var tools_menu = $ToolsMenu
	tools_menu.create_tool_buttons(tool_config["tools"])
	tools_menu.tool_selected.connect(_on_tool_select)
	_on_tool_select(tool_config["tools"][0])

func _on_tool_select(tool):
	$Canvas.select_mixer(tool)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
