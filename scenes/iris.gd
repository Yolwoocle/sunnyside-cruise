extends ColorRect

@onready var title_text = $TitleText

func _ready():
	material.set_shader_parameter("radius", 0.0)

func hide_text():
	title_text.hide()
