extends Button

var action_map = {
	"Reset": "ui_reset",
	"Save": "ui_save",
	"Undo": "ui_undo"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	if !action_map.has(name):
		return
		
	var action_name = action_map[name]
	trigger_action(action_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func trigger_action(action_name):
	var custom_event = InputEventAction.new()
	custom_event.action = action_name
	custom_event.pressed = true
	Input.parse_input_event(custom_event)
