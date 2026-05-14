extends Camera2D

@export var scroll_multiplier = 0.001

func _process(delta: float) -> void:
	global_position.x = (-50.0 + $"../Bike".body.global_position.x)
	
	var water_material: ShaderMaterial = $Water.material
	water_material.set_shader_parameter("scroll", position.x * scroll_multiplier)
