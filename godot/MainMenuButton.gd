class_name MainMenuButton extends Button

@export_enum("ui_credits", "ui_info", "ui_new", "ui_quit", "ui_random", "ui_reset", "ui_save", "ui_undo") var action_name: String = "ui_credits"

func _pressed():
	trigger_action(action_name)

func trigger_action(name):
	var custom_event = InputEventAction.new()
	custom_event.action = name
	custom_event.pressed = true
	Input.parse_input_event(custom_event)
