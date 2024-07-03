extends Modal


# Called when the node enters the scene tree for the first time.
func _ready():
	$CloseButton.pressed.connect(close)
	$Text.meta_clicked.connect(_on_link_clicked)

func _on_open():
	focus_on_first_control()
	
func focus_on_first_control():
	$CloseButton.grab_focus()
