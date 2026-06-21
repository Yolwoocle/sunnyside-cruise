extends Node2D

@onready var iris: ColorRect = $Camera2D/Iris
@onready var music_player: AudioStreamPlayer2D = $Camera2D/MusicPlayer

func _process(delta: float) -> void:
	$Camera2D/Label.text = str(Engine.get_frames_per_second()) + "FPS"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		start()


func start():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	var mat: ShaderMaterial = iris.material
	tween.tween_callback(func(): iris.hide_text())
	tween.tween_interval(1.0)
	tween.tween_callback(func(): music_player.play())
	tween.tween_method(
		func(val): mat.set_shader_parameter("radius", val), 
		0, 60, 0.5
	)
	tween.tween_interval(1.0)
	tween.tween_method(
		func(val): mat.set_shader_parameter("radius", val), 
		60, 600, 0.75
	)
