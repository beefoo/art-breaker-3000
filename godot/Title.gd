extends Modal

var time = 0.0

@onready var image_shader = $ImageContainer/TextureRect.material
@onready var text_shader = $TitleContainer/TextureRect.material

func custom_process(delta):
	time += delta
	image_shader.set_shader_parameter("time", time)
	text_shader.set_shader_parameter("time", time)

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.pressed.connect(close)
	focus_on_first_control()
	$BackgroundAudioPlayer.play(0.0)

func close(with_sound=true):
	$BackgroundAudioPlayer.stop()
	animate_out()	
	closed.emit()

func focus_on_first_control():
	$StartButton.grab_focus()
