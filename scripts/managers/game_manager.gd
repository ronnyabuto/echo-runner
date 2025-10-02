extends Node

signal score_changed(new_score: int)
signal level_completed(level_name: String, score: int, time: float)
signal game_over

var current_score: int = 0
var current_level: String = ""
var level_start_time: float = 0.0
var high_scores: Dictionary = {}
var game_settings: Dictionary = {
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"music_volume": 0.7,
	"accessibility_mode": false,
	"screen_shake": true,
	"particle_effects": true
}

const SAVE_PATH: String = "user://save_game.json"
const SETTINGS_PATH: String = "user://settings.json"

func _ready() -> void:
	load_settings()
	load_high_scores()

func start_level(level_name: String) -> void:
	current_level = level_name
	current_score = 0
	level_start_time = Time.get_ticks_msec() / 1000.0
	score_changed.emit(current_score)

func add_score(points: int) -> void:
	current_score += points
	score_changed.emit(current_score)

func complete_level() -> void:
	var completion_time: float = (Time.get_ticks_msec() / 1000.0) - level_start_time

	if not high_scores.has(current_level) or current_score > high_scores[current_level]["score"]:
		high_scores[current_level] = {
			"score": current_score,
			"time": completion_time
		}
		save_high_scores()

	level_completed.emit(current_level, current_score, completion_time)

func player_died() -> void:
	game_over.emit()

func reset_game() -> void:
	current_score = 0
	current_level = ""
	score_changed.emit(current_score)

func get_high_score(level_name: String) -> int:
	if high_scores.has(level_name):
		return high_scores[level_name]["score"]
	return 0

func get_best_time(level_name: String) -> float:
	if high_scores.has(level_name):
		return high_scores[level_name]["time"]
	return 0.0

func save_high_scores() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(high_scores))
		file.close()

func load_high_scores() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string: String = file.get_as_text()
			file.close()
			var json: JSON = JSON.new()
			var parse_result: Error = json.parse(json_string)
			if parse_result == OK:
				high_scores = json.data

func save_settings() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(game_settings))
		file.close()

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var json_string: String = file.get_as_text()
			file.close()
			var json: JSON = JSON.new()
			var parse_result: Error = json.parse(json_string)
			if parse_result == OK:
				game_settings = json.data
	apply_settings()

func apply_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
		linear_to_db(game_settings.get("master_volume", 1.0)))

func update_setting(key: String, value) -> void:
	game_settings[key] = value
	apply_settings()
	save_settings()

func get_setting(key: String, default_value = null):
	return game_settings.get(key, default_value)
