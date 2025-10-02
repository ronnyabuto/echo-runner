extends CanvasLayer

signal next_level_requested
signal retry_requested
signal menu_requested

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var score_label: Label = $Panel/ScoreLabel
@onready var time_label: Label = $Panel/TimeLabel
@onready var voices_label: Label = $Panel/VoicesLabel
@onready var next_button: Button = $Panel/VBoxContainer/NextButton
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton

var is_victory: bool = true
var final_score: int = 0
var completion_time: float = 0.0
var voices_collected: int = 0

func _ready() -> void:
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)

func _on_level_completed(level_name: String, score: int, time: float) -> void:
	show_victory(score, time)

func _on_game_over() -> void:
	show_defeat()

func show_victory(score: int, time: float) -> void:
	is_victory = true
	final_score = score
	completion_time = time

	title_label.text = "LEVEL COMPLETE!"
	title_label.modulate = Color(0.3, 1.0, 0.4)
	score_label.text = "Score: " + str(score)
	time_label.text = "Time: %.1fs" % time

	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_voices_count"):
		voices_collected = player.get_voices_count()
		voices_label.text = "Voices Collected: " + str(voices_collected)

	next_button.visible = true
	visible = true
	get_tree().paused = true

func show_defeat() -> void:
	is_victory = false

	title_label.text = "GAME OVER"
	title_label.modulate = Color(1.0, 0.3, 0.3)
	score_label.text = "Score: " + str(GameManager.current_score)
	time_label.text = ""
	voices_label.text = ""

	next_button.visible = false
	visible = true
	get_tree().paused = true

func _on_next_pressed() -> void:
	get_tree().paused = false
	next_level_requested.emit()

	var current_scene: String = get_tree().current_scene.scene_file_path
	var next_scene: String = ""

	match current_scene:
		"res://scenes/levels/Level1_RallyRow.tscn":
			next_scene = "res://scenes/levels/Level2_MediaMaze.tscn"
		"res://scenes/levels/Level2_MediaMaze.tscn":
			next_scene = "res://scenes/levels/Level3_LobbyLane.tscn"
		"res://scenes/levels/Level3_LobbyLane.tscn":
			next_scene = "res://scenes/levels/Level4_ElectionFactory.tscn"
		_:
			next_scene = "res://scenes/ui/MainMenu.tscn"

	get_tree().change_scene_to_file(next_scene)

func _on_retry_pressed() -> void:
	get_tree().paused = false
	retry_requested.emit()
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	menu_requested.emit()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
