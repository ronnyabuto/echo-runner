extends Control

@onready var master_volume_slider: HSlider = $VBoxContainer/MasterVolume/Slider
@onready var sfx_volume_slider: HSlider = $VBoxContainer/SFXVolume/Slider
@onready var music_volume_slider: HSlider = $VBoxContainer/MusicVolume/Slider
@onready var screen_shake_check: CheckBox = $VBoxContainer/ScreenShake/CheckBox
@onready var accessibility_check: CheckBox = $VBoxContainer/Accessibility/CheckBox
@onready var back_button: Button = $BackButton

func _ready() -> void:
	master_volume_slider.value = GameManager.get_setting("master_volume", 1.0) * 100
	sfx_volume_slider.value = GameManager.get_setting("sfx_volume", 1.0) * 100
	music_volume_slider.value = GameManager.get_setting("music_volume", 0.7) * 100
	screen_shake_check.button_pressed = GameManager.get_setting("screen_shake", true)
	accessibility_check.button_pressed = GameManager.get_setting("accessibility_mode", false)

	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	screen_shake_check.toggled.connect(_on_screen_shake_toggled)
	accessibility_check.toggled.connect(_on_accessibility_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _on_master_volume_changed(value: float) -> void:
	GameManager.update_setting("master_volume", value / 100.0)

func _on_sfx_volume_changed(value: float) -> void:
	GameManager.update_setting("sfx_volume", value / 100.0)
	AudioManager.set_sfx_volume(value / 100.0)

func _on_music_volume_changed(value: float) -> void:
	GameManager.update_setting("music_volume", value / 100.0)
	AudioManager.set_music_volume(value / 100.0)

func _on_screen_shake_toggled(enabled: bool) -> void:
	GameManager.update_setting("screen_shake", enabled)

func _on_accessibility_toggled(enabled: bool) -> void:
	GameManager.update_setting("accessibility_mode", enabled)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
