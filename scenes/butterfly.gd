extends AnimatedSprite2D

var reference_position: Vector2

var _t = 0.0
var _cos_scale: float
var _sin_scale: float
var _cos_amplitude: float
var _sin_amplitude: float

func _ready() -> void:
	reference_position = position
	var anim_speed = randf_range(0.9, 1.1)
	play("default", anim_speed)
	if randf() < 0.3:
		play("default_pink", anim_speed)
	
	_cos_scale = randf_range(1.0, 3.0)
	_sin_scale = randf_range(1.0, 3.0)
	_cos_amplitude = randf_range(4.0, 16.0)
	_sin_amplitude = randf_range(4.0, 16.0)
	
	if randf() < 0.5:
		z_index = -5

func _physics_process(delta: float) -> void:
	_t += delta
	
	var old_pos = Vector2(position)
	position = reference_position + Vector2(cos(_t * _cos_scale) * _cos_amplitude, sin(_t * _sin_scale) * _sin_amplitude)
	
	flip_h = (old_pos > position)
