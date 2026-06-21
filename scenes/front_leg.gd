extends Node2D

@export var leg_length = 10

@onready var leg: Line2D = $LegFrontLine2D

func _ready() -> void:
	leg.clear_points()
	for i in 3:
		leg.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	leg.global_position = Vector2.ZERO
	leg.set_point_position(0, $FrontLegBase.global_position)
	
	var coll_shape_1 = $LegFront/CollisionShape2D.shape as CapsuleShape2D
	leg.set_point_position(1, $LegFront.global_transform * (Vector2.UP * coll_shape_1.height * 0.5))
	
	var coll_shape_2 = $LegFront/CollisionShape2D.shape as CapsuleShape2D
	leg.set_point_position(2, $KneeFront.global_transform * (Vector2.DOWN * coll_shape_2.height * 0.5))
