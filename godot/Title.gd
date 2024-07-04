extends Modal

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.pressed.connect(close)
	focus_on_first_control()
	$BackgroundAudioPlayer.play(0.0)

func animate_step(n):
	set_modulate(Color(1, 1, 1, 1.0 - n))

func close(with_sound=true):
	$BackgroundAudioPlayer.stop()
	animate_out()	
	closed.emit()

func focus_on_first_control():
	$StartButton.grab_focus()
