extends Camera2D

@export var target_offset = Vector2(-100.0, 0.0)
@export var scroll_multiplier = 0.001

func _process(delta: float) -> void:
	global_position.x = (target_offset.x + $"../Bike".body.global_position.x)
	
	var water_material: ShaderMaterial = $Water.material
	water_material.set_shader_parameter("scroll", position.x * scroll_multiplier)
