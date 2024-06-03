extends TextureButton

var button_groups = []
var button_group_count = 0
var active_group_i = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	button_groups = get_parent().get_children().filter(func(node): return node.get_class() == "VBoxContainer")
	button_group_count = button_groups.size()
	show_active_group()

func _pressed():
	active_group_i += 1
	if active_group_i >= button_group_count:
		active_group_i = 0
	show_active_group()
	
func show_active_group():
	var group_number = active_group_i + 1
	$Label.text = "{group_number}".format({"group_number": group_number})
	for i in range(button_group_count):
		if i == active_group_i:
			button_groups[i].animate_in()
		else:
			button_groups[i].animate_out()
