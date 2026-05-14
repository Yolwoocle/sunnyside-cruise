extends Node2D

@export var size = 20

var grass_field_prefab: PackedScene = load("res://scenes/grass_field.tscn")

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	for i in size:
		var chunk = grass_field_prefab.instantiate()
		var x = viewport_size.x * i
		chunk.global_position = Vector2(x, 0.0)
		chunk.terrain_offset = x
		add_child(chunk)
