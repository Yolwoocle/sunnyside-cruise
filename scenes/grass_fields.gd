extends Node2D

@export var size = 20
@export var base_height: float = 180
@export var first_chunk_randomness_curve: Curve

var grass_field_prefab: PackedScene = load("res://scenes/grass_field.tscn")
var seed: int


func _ready() -> void:
	seed = randi()
	
	var viewport_size = get_viewport_rect().size
	for i in range(-1, size):
		var chunk: GrassFieldChunk = grass_field_prefab.instantiate()
		var x = viewport_size.x * i
		chunk.terrain_seed = seed
		chunk.global_position = Vector2(x, 0.0)
		chunk.terrain_offset = x
		if first_chunk_randomness_curve and i == -1 and first_chunk_randomness_curve.point_count > 0:
			var y = first_chunk_randomness_curve.get_point_position(0).y
			chunk.randomness_curve = Curve.new()
			chunk.randomness_curve.add_point(Vector2(0, y), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
			chunk.randomness_curve.add_point(Vector2(1, y), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
			chunk.randomness_curve_base_height = base_height
		if first_chunk_randomness_curve and i == 0:
			chunk.randomness_curve = first_chunk_randomness_curve
			chunk.randomness_curve_base_height = base_height
		add_child(chunk)
