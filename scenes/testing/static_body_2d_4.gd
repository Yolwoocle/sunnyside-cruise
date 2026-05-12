extends StaticBody2D

var pressed = false
var anchor = Vector2.ZERO

func _process(delta: float) -> void:
	if pressed:
		var pos = get_global_mouse_position() - anchor
		global_position = pos
	else:
		pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				pressed = true
				anchor = Vector2.ZERO
			else:
				pressed = false
				anchor = Vector2.ZERO
				
