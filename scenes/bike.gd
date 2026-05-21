extends Node2D

@export var advance_force = 600

@onready var back_wheel = $BackWheel
@onready var body = $BikeBody
@onready var pedal: Node2D = $BikeBody/Pedal

var previous_wheel_rotation = 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var body_rot = body.rotation
	
	if Input.is_action_pressed("game_left"):
		back_wheel.apply_force(Vector2.LEFT.rotated(body_rot) * advance_force)
	if Input.is_action_pressed("game_right"):
		back_wheel.apply_force(Vector2.RIGHT.rotated(body_rot) * advance_force)
		
		var diff = angle_difference(previous_wheel_rotation, back_wheel.rotation)
		if diff > 0:
			pedal.set_pedal_rotation_speed(diff / delta)
	
	previous_wheel_rotation = back_wheel.rotation
