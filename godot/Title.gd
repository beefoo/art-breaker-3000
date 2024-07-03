extends Modal


# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.pressed.connect(close)

func _on_open():
	focus_on_first_control()
	
func close():
	animate_out()
	audio_player.stop()
	closed.emit()

func focus_on_first_control():
	$StartButton.grab_focus()

func play_sound():
	audio_player.play(0.0)
