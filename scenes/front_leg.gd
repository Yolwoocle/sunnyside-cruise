extends Node2D

@onready var leg: Line2D = $LegFrontLine2D

func _ready() -> void:
	leg.clear_points()
	for i in 3:
		leg.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	leg.global_position = Vector2.ZERO
	leg.set_point_position(0, $FrontLegBase.global_position)
	leg.set_point_position(1, $PedalHeadFront.global_position)
	leg.set_point_position(2, $PedalHeadFront.global_position)
