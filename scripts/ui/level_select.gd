extends Control

@onready var level_container: VBoxContainer = $ScrollContainer/LevelContainer
@onready var back_button: Button = $BackButton

var level_data: Array = [
	{
		"name": "Rally Row",
		"scene": "res://scenes/levels/Level1_RallyRow.tscn",
		"description": "Beginner level with basic obstacles"
	},
	{
		"name": "Media Maze",
		"scene": "res://scenes/levels/Level2_MediaMaze.tscn",
		"description": "Moving platforms and headline hazards"
	},
	{
		"name": "Lobby Lane",
		"scene": "res://scenes/levels/Level3_LobbyLane.tscn",
		"description": "Face the Lobbyist mid-boss"
	},
	{
		"name": "Election Factory",
		"scene": "res://scenes/levels/Level4_ElectionFactory.tscn",
		"description": "Final showdown with Machine Candidate"
	}
]

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	populate_level_list()

func populate_level_list() -> void:
	for level in level_data:
		var level_button: Button = Button.new()
		level_button.text = level["name"]
		level_button.custom_minimum_size = Vector2(400, 60)

		var high_score: int = GameManager.get_high_score(level["name"])
		var best_time: float = GameManager.get_best_time(level["name"])

		level_button.tooltip_text = level["description"]
		if high_score > 0:
			level_button.tooltip_text += "\nHigh Score: " + str(high_score)
			level_button.tooltip_text += "\nBest Time: " + "%.1fs" % best_time

		level_button.pressed.connect(_on_level_selected.bind(level["scene"]))
		level_container.add_child(level_button)

		var info_label: Label = Label.new()
		if high_score > 0:
			info_label.text = "High Score: %d | Time: %.1fs" % [high_score, best_time]
		else:
			info_label.text = "Not yet completed"
		info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_container.add_child(info_label)

		var spacer: Control = Control.new()
		spacer.custom_minimum_size = Vector2(0, 20)
		level_container.add_child(spacer)

func _on_level_selected(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
