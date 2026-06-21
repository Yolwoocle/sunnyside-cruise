extends RigidBody2D

@export var front_leg_base: AnimatableBody2D
@export var back_leg_base: AnimatableBody2D
@onready var bunny_head: Sprite2D = $BunnyHead
@onready var bunny_head_marker: Marker2D = $BunnyHeadMarker

func _physics_process(delta: float) -> void:
	front_leg_base.global_transform = $LegBaseFrontMarker.global_transform
	back_leg_base.global_transform = $LegBaseBackMarker.global_transform
	
	bunny_head.global_position = (bunny_head_marker.global_position)
	bunny_head.global_rotation = 0.0
