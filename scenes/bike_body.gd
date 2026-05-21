extends RigidBody2D

@export var front_leg_base: AnimatableBody2D

func _physics_process(delta: float) -> void:
	front_leg_base.global_transform = $LegBaseMarker.global_transform
