extends Button

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# resize and position animated sprite
	var container = get_parent()
	var container_w = container.size.x
	var sprite_w = sprite.sprite_frames.get_frame_texture("default", 0).get_size().x
	var sep = get_theme_constant("h_separation")
	var new_sprite_w = container_w - sep * 2
	var sprite_scale = new_sprite_w / sprite_w
	var new_sprite_scale = Vector2(sprite_scale, sprite_scale)
	var new_sprite_position = Vector2(sep, sep)
	sprite.set_position(new_sprite_position)
	sprite.set_scale(new_sprite_scale)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hide_animation():
	sprite.hide()
	sprite.stop()

func show_animation():
	sprite.show()
	sprite.play()
