extends Control

var tool_config = {
	"tools": [
		{"name": "BandShuffle", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "Multiplier", "icon": "art/icons/copy.svg", "shader_params": []},
		{"name": "ColorCycle", "icon": "art/icons/shuffle.svg", "shader_params": []},
		{"name": "PolkaDots", "icon": "art/icons/copy.svg", "shader_params": ["aspect_ratio"]}
	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var tools_menu = $ToolsMenu
	tools_menu.create_buttons(tool_config["tools"])
	tools_menu.tool_selected.connect(_on_tool_select)
	_on_tool_select(tool_config["tools"][0])

func _on_tool_select(tool):
	$Canvas.select_mixer(tool)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
