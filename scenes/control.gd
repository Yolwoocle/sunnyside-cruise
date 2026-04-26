extends Control

var iris_radius := 0.0

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var iris = $Iris
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		
		var material: ShaderMaterial = iris.material
		tween.tween_interval(1.0)
		tween.tween_method(
			func(val): material.set_shader_parameter("radius", val), 
			0, 60, 0.5
		)
		tween.tween_interval(1.0)
		tween.tween_method(
			func(val): material.set_shader_parameter("radius", val), 
			60, 600, 0.75
		)
