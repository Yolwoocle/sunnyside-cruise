extends RigidBody2D

@export var front_leg_base: AnimatableBody2D
@export var back_leg_base: AnimatableBody2D

func _physics_process(delta: float) -> void:
	front_leg_base.global_transform = $LegBaseFrontMarker.global_transform
	back_leg_base.global_transform = $LegBaseBackMarker.global_transform
