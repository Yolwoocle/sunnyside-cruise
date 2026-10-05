extends Node

@onready var iris: ColorRect = %Iris
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var bike: Bike = %Bike
@onready var start_canvas_layer: CanvasLayer = $UICanvasLayer
@onready var pause_layer: CanvasLayer = $PauseLayer

var started = false

func _ready() -> void:
	start_canvas_layer.show()
	bike.is_static = true


func _process(delta: float) -> void:
	%FPSLabel.text = ""
	%FPSLabel.text += str(Engine.get_frames_per_second()) + "FPS\n"
	%FPSLabel.text += str($GameLayer/Camera2D.global_position) + "\n"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_bell") and not started:
		start()


func start():
	started = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	var mat: ShaderMaterial = iris.material
	# Hide text
	tween.tween_callback(func(): iris.hide_text())
	tween.tween_interval(1.0)
	
	# Start music
	tween.tween_callback(func(): music_player.play())
	
	# Open iris
	tween.tween_method(
		func(val): mat.set_shader_parameter("radius", val), 
		0, 60, 0.5
	)
	tween.tween_interval(0.1)
	tween.tween_callback(
		func():
			bike.is_static = false
			bike.ring_bell()
	)
	
	tween.tween_interval(1.0)
	tween.tween_method(
		func(val): mat.set_shader_parameter("radius", val), 
		60, 600, 0.75
	)
	tween.tween_callback(func(): pause_layer.can_pause = true)
