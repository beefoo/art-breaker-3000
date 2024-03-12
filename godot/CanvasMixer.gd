# The direct child of Canvas, that "mixes" the current texture

extends Control

var is_active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_size(get_parent().size)
	set_position(Vector2.ZERO)
	# If not visible, assume disabled
	if not visible:
		deactivate()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Show and enable processing
func activate():
	is_active = true
	set_process(true)
	show()

# Hide and disable processing
func deactivate():
	is_active = false;
	set_process(false)
	hide()

func set_params(params):
	for property in params:
		var value = params[property]
		material.set_shader_parameter(property, value)
