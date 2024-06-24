extends AudioStreamPlayer

@export_enum("ease_in", "pointer", "wave", "velocity") var effect_mode: String
@export_enum("Pitch", "Scale", "Delay", "Distortion", "Filter", "Volume") var effect_property: String = "Pitch"
@export var effect_dur = -1.0
@export var effect_min = -1.0
@export var effect_max = -1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

