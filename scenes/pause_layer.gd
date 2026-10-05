extends CanvasLayer

@onready var slider_sfx: VSlider = %SliderSFX
@onready var slider_music: VSlider = %SliderMusic
@onready var pause_menu: Control = $PauseMenu
@onready var buttons: VBoxContainer = %Buttons
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton

var paused = false
var can_pause = false

var tween: Tween

func _ready() -> void:
	hide()
	slider_sfx.value_changed.connect(_on_slider_sfx_changed)
	slider_music.value_changed.connect(_on_slider_music_changed)
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		if not can_pause:
			return
		if not paused:
			paused = true
			get_tree().paused = true
			AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, true)
			
			show()
			if tween: tween.kill()
			tween = create_tween()
			tween.tween_property(pause_menu, "modulate:a", 1.0, 0.1).from(0.0)
			
			(buttons.get_child(0) as Button).grab_focus()
		else:
			paused = false
			get_tree().paused = false
			AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, false)
			
			show()
			if tween: tween.kill()
			tween = create_tween()
			tween.tween_property(pause_menu, "modulate:a", 0.0, 0.1).from(1.0)
			tween.tween_callback(hide)


func _on_slider_sfx_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambiance"), linear_to_db(value) - 3.0)


func _on_slider_music_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value) - 6.0)


func _on_resume_button_pressed():
	pass


func _on_quit_button_pressed():
	pass
