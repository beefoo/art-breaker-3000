extends Panel

signal tool_selected(tool)

var tool_buttons = []
var nav_buttons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_press_tool_button(button, tool):
	tool_selected.emit(tool)
	
func _on_press_nav_button(group_index):
	var group_count = nav_buttons.size()
	var next_group = group_index + 1
	nav_buttons[group_index].hide()
	if next_group >= group_count:
		next_group = 0
	nav_buttons[next_group].show()
	for button in tool_buttons:
		button["gd_button"].visible = button["group"] == next_group

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_tool_button(props):
	var button = Button.new()
	var texture = load("res://%s" % props["icon"])
	var on_press = func():
		_on_press_tool_button(button, props.duplicate())
		
	button.set_size(props["size"])
	button.set_position(props["position"])
	button.icon = texture
	button.expand_icon = true
	button.visible = props["group"] == 0
	button.pressed.connect(on_press)
	add_child(button)
	return button
	
func create_tool_buttons(buttons):
	var panel_h = size.y
	var panel_w = size.x
	var btn_w = panel_w
	var btn_h = btn_w
	var btn_x = 0.0
	var btns_per_group = round(panel_h / btn_h) - 1
	var index = 0
	var group = 0
	var row = 0
	for button in buttons:
		var btn_y = row * btn_h;
		button["size"] = Vector2(btn_w, btn_h)
		button["position"] = Vector2(btn_x, btn_y)
		button["index"] = index
		button["group"] = group
		button["gd_button"] = create_tool_button(button)
		buttons[index] = button
		row += 1
		index += 1
		if row >= btns_per_group:
			row = 0
			group += 1
	tool_buttons = buttons
	if buttons.size() > btns_per_group:
		create_nav_buttons(ceil(float(buttons.size()) / btns_per_group))
		
func create_nav_buttons(count):
	var texture = load("res://art/icons/arrow.svg")
	var panel_h = size.y
	var panel_w = size.x
	var btn_w = panel_w
	var btn_h = btn_w
	var btn_x = 0.0
	var btn_y = panel_h - btn_h;
	
	for i in range(count):
		var button = Button.new()
		var on_press = func():
			_on_press_nav_button(i)
		button.set_size(Vector2(btn_w, btn_h))
		button.set_position(Vector2(btn_x, btn_y))
		button.icon = texture
		button.expand_icon = true
		button.visible = i == 0
		button.pressed.connect(on_press)
		nav_buttons.append(button)
		add_child(button)
		
