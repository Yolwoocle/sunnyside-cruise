extends Camera2D

@export var target_offset = Vector2(-100.0, 0.0)
@export var bike: Bike

func _process(delta: float) -> void:
	global_position.x = max(target_offset.x + bike.body.global_position.x, 0.0)
