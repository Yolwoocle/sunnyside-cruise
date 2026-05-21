extends Node2D

var pedal_length = 5.0
var pedal_rotation = 0.0
var pedal_rotation_speed = 0.0
var pedal_rotation_deceleration = 3.0
var pedal_thickness_offset = 2.0

@export var pedal_head_front_body: AnimatableBody2D
@export var pedal_head_back_body: AnimatableBody2D

func add_pedal_rotation(angle: float) -> void:
	set_pedal_rotation(pedal_rotation + angle)

func set_pedal_rotation(angle: float) -> void:
	pedal_rotation = angle
	
	$PedalFront.rotation = angle
	$PedalBack.rotation = angle + PI
	
	$PedalHeadFront.position = Vector2.RIGHT.rotated(angle) * pedal_length
	$PedalHeadBack.position = Vector2.RIGHT.rotated(angle + PI) * pedal_length

func set_pedal_rotation_speed(speed: float) -> void:
	pedal_rotation_speed = speed

func _physics_process(delta: float) -> void:
	add_pedal_rotation(pedal_rotation_speed * delta)
	
	pedal_rotation_speed = move_toward(pedal_rotation_speed, 0.0, delta * pedal_rotation_deceleration)
	pedal_head_front_body.global_position = $PedalHeadFront.global_position + Vector2.UP * pedal_thickness_offset
	pedal_head_back_body.global_position = $PedalHeadBack.global_position + Vector2.UP * pedal_thickness_offset
