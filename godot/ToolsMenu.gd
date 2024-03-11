extends Panel

signal tool_selected(name)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_press_button(button, name):
	tool_selected.emit(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_button(props):
	var button = Button.new()
	var texture = load("res://%s" % props["icon"])
	var on_press = func():
		_on_press_button(button, props["name"])
		pass
		
	button.set_size(props["size"])
	button.set_position(props["position"])
	button.icon = texture
	button.expand_icon = true
	button.pressed.connect(on_press)
	add_child(button)
	
func create_buttons(buttons):
	var btn_w = size.x
	var btn_h = btn_w
	var btn_x = 0.0
	var btn_y = 0.0
	for button in buttons:
		button["size"] = Vector2(btn_w, btn_h)
		button["position"] = Vector2(btn_x, btn_y)
		create_button(button)
		btn_y += btn_h
