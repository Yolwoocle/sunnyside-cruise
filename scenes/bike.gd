extends Node2D

@export var advance_force = 600

@onready var back_wheel = $BackWheel
@onready var body = $BikeBody

var pedal_state = true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var body_rot = body.rotation
	
	if Input.is_action_pressed("game_left"):
		back_wheel.apply_force(Vector2.LEFT.rotated(body_rot) * advance_force)
	if Input.is_action_pressed("game_right"):
		back_wheel.apply_force(Vector2.RIGHT.rotated(body_rot) * advance_force)
