extends Panel

signal tool_selected(tool, from_user)

var button_groups = []
var active_button_i = -1
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
	nav_buttons[group_index].animate_out()
	if next_group >= group_count:
		next_group = 0
	nav_buttons[next_group].animate_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func activate_tool_button(tool_name):
	for group in button_groups:
		for button in group.get_children():
				button.set_active(button.name == tool_name)
				
func focus_on_first_control():
	var active_found = false
	for group in button_groups:
		for button in group.get_children():
				if button.is_active:
					button.grab_focus()
					active_found = true
					break
		if active_found:
			break
	if not active_found:
		button_groups[0].get_children()[0].grab_focus()

func init_tool_button(button):
	var on_press = func():
		_on_press_tool_button(button.name)
	button.pressed.connect(on_press)

func init_tool_buttons():
	for group in button_groups:
		for button in group.get_children():
			init_tool_button(button)
