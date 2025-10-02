extends Node2D
class_name BaseLevel

signal level_completed
signal player_spawn_ready(spawn_position: Vector2)

@export var level_name: String = "Level"
@export var time_limit: float = 180.0
@export var collectible_goal: int = 20

var player_scene: PackedScene = preload("res://scenes/player/Player.tscn")
var shockwave_scene: PackedScene = preload("res://scenes/player/Shockwave.tscn")
var player: Player = null
var elapsed_time: float = 0.0
var is_level_complete: bool = false

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var level_exit: Area2D = $LevelExit
@onready var tilemap: TileMap = $TileMap

func _ready() -> void:
	GameManager.start_level(level_name)
	spawn_player()

	if level_exit:
		level_exit.body_entered.connect(_on_level_exit_entered)

func _process(delta: float) -> void:
	if is_level_complete:
		return

	elapsed_time += delta

	if time_limit > 0 and elapsed_time >= time_limit:
		player_died()

func spawn_player() -> void:
	if player_scene:
		player = player_scene.instantiate()
		add_child(player)

		if player_spawn:
			player.global_position = player_spawn.global_position
		else:
			player.global_position = Vector2(100, 300)

		player.shockwave_fired.connect(_on_player_shockwave_fired)
		player.player_died.connect(_on_player_died)

		player_spawn_ready.emit(player.global_position)

func _on_player_shockwave_fired(position: Vector2, power: float) -> void:
	if shockwave_scene:
		var shockwave: Shockwave = shockwave_scene.instantiate()
		add_child(shockwave)
		shockwave.initialize(position, power)

func _on_level_exit_entered(body: Node2D) -> void:
	if body == player and not is_level_complete:
		complete_level()

func complete_level() -> void:
	is_level_complete = true
	GameManager.complete_level()
	level_completed.emit()

func player_died() -> void:
	GameManager.player_died()

func _on_player_died() -> void:
	player_died()

func get_elapsed_time() -> float:
	return elapsed_time

func get_time_remaining() -> float:
	if time_limit > 0:
		return max(0, time_limit - elapsed_time)
	return 0.0
