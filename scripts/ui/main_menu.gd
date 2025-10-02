extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var level_select_button: Button = $VBoxContainer/LevelSelectButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $TitleLabel
@onready var high_score_label: Label = $HighScoreLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	update_high_score_display()

func update_high_score_display() -> void:
	var total_high_score: int = 0
	for level_name in ["Rally Row", "Media Maze", "Lobby Lane", "Election Factory"]:
		total_high_score += GameManager.get_high_score(level_name)

	if high_score_label:
		high_score_label.text = "Best Total Score: " + str(total_high_score)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Level1_RallyRow.tscn")

func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
