extends CanvasLayer

@export var scroll_multiplier = 0.001
@export var camera: Camera2D

func _process(delta: float) -> void:
	var water_material: ShaderMaterial = $Water.material
	water_material.set_shader_parameter("scroll", camera.position.x * scroll_multiplier)
