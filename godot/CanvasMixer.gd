extends Control

var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_size(get_parent().size)
	set_position(Vector2.ZERO)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_active:
		return
	
func activate():
	is_active = true
	show()

func deactivate():
	is_active = false;
	hide()

func set_params(params):
	for name in params:
		var value = params[name]
		material.set_shader_parameter(name, value)
