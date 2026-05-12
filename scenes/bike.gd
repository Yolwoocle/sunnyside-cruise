extends Node2D

@onready var back_wheel = $BackWheel
@export var advance_force = 200

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		back_wheel.apply_force(Vector2.LEFT * advance_force)
	if Input.is_action_pressed("ui_right"):
		back_wheel.apply_force(Vector2.RIGHT * advance_force)
