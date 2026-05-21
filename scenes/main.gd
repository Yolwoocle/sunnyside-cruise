extends Node2D

func _process(delta: float) -> void:
	$Camera2D/Label.text = str(Engine.get_frames_per_second()) + "FPS"
