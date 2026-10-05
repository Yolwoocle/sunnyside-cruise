class_name Bike
extends Node2D

@export var default_advance_force = 300

@onready var back_wheel = $BackWheel
@onready var body = $BikeBody
@onready var pedal: Node2D = $BikeBody/Pedal
@onready var bell_sound: AudioStreamPlayer2D = %BellSound
@onready var bell_particles: Node2D = %BellParticles
@onready var wheel_sound: AudioStreamPlayer2D = $BackWheel/WheelSound
@onready var head: Sprite2D = $BikeBody/BunnyHead

var advance_force = 0.0

var previous_wheel_rotation = 0.0
var is_static = false

const rolling_sfx_velocity_cap = 150.0

var blink_timer = 0.0
const blink_min = 1.5
const blink_max = 2.0
const blink_duration = 0.1

func _ready() -> void:
	wheel_sound.volume_linear = 0.0
	wheel_sound.play()

func _physics_process(delta: float) -> void:
	if is_static:
		return 
	
	var axis = Input.get_axis("game_left", "game_right")
	if abs(axis) > 0.01:
		move(axis * advance_force)
		
		if axis > 0:
			var diff = angle_difference(previous_wheel_rotation, back_wheel.rotation)
			if diff > 0:
				pedal.set_pedal_rotation_speed(diff / delta)
	else:
		advance_force = default_advance_force
	
	previous_wheel_rotation = back_wheel.rotation
	
	wheel_sound.volume_linear = clamp(remap(body.linear_velocity.length(), 0.0, rolling_sfx_velocity_cap, 0.0, 1.0), 0.0, 1.0)
	
	blink_timer -= delta 
	if blink_timer < 0.0:
		head.frame = 1
		if blink_timer < -blink_duration:
			blink_timer = randf_range(blink_min, blink_max)
	else:
		head.frame = 0


func move(force: float) -> void:
	var body_rot = body.rotation
	back_wheel.apply_force(Vector2.RIGHT.rotated(body_rot) * force)


func _input(event: InputEvent) -> void:
	if is_static:
		return
	
	if event.is_action_pressed("game_bell"):
		ring_bell()


func ring_bell():
	bell_sound.play()
	bell_particles.play()
