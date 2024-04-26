extends Modal

var title_template

# Called when the node enters the scene tree for the first time.
func _ready():
	title_template = ""
	title_template += "[font_size=80]{Title}[/font_size]\n\n"
	title_template += "[font_size=60][color=#dddddd]{Creator}, {Date}[/color][/font_size]\n"
	title_template += "[url={URL}][font_size=60][color=#f7de38]{Source}[/color][/font_size][/url]"
	
	$TextContainer/CloseButton.pressed.connect(close)
	$TextContainer/Text.meta_clicked.connect(_on_link_clicked)

func _on_link_clicked(url):
	OS.shell_open(url)

func set_item(texture, data):
	$ImageContainer/TextureRect.set_texture(texture.duplicate())
	$TextContainer/Text.set_text(title_template.format(data))
