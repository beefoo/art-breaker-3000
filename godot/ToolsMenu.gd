extends Panel

signal tool_selected(tool, from_user)

var button_groups = []
var active_button_i = -1
var tool_buttons = []
var nav_buttons = []
var button_margin = 6.0

# Called when the node enters the scene tree for the first time.
func _ready():
	button_groups = get_children().filter(func(n): return n.get_class() == "VBoxContainer")

func _on_press_tool_button(tool_name):
	tool_selected.emit(tool_name, true)
	
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
	
func activate_tool_button(tool_name):
	for group in button_groups:
		for button in group.get_children():
				button.set_active(button.name == tool_name)

func init_tool_button(button):
	var on_press = func():
		_on_press_tool_button(button.name)
	button.pressed.connect(on_press)

func init_tool_buttons():
	for group in button_groups:
		for button in group.get_children():
			init_tool_button(button)
		
func create_nav_buttons(count):
	var texture = load("res://art/icons/arrow.svg")
	var panel_h = size.y
	var panel_w = size.x
	var btn_w = panel_w - button_margin * 2.0
	var btn_h = btn_w
	var btn_x = button_margin
	var btn_y = panel_h - btn_h - button_margin;
	
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
		
