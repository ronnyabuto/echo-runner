extends Node

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
const MAX_SFX_PLAYERS: int = 16
var current_sfx_index: int = 0

var sfx_library: Dictionary = {}
var music_library: Dictionary = {}

func _ready() -> void:
	for i in range(MAX_SFX_PLAYERS):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		sfx_players.append(player)

	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"

	setup_placeholder_audio()

func setup_placeholder_audio() -> void:
	pass

func play_sfx(sfx_name: String, volume_db: float = 0.0) -> void:
	if sfx_library.has(sfx_name):
		var player: AudioStreamPlayer = sfx_players[current_sfx_index]
		current_sfx_index = (current_sfx_index + 1) % MAX_SFX_PLAYERS

		player.stream = sfx_library[sfx_name]
		player.volume_db = volume_db
		player.play()

func play_music(music_name: String, loop: bool = true) -> void:
	if music_library.has(music_name):
		music_player.stream = music_library[music_name]
		music_player.play()

func stop_music() -> void:
	music_player.stop()

func set_sfx_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volume))

func set_music_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))

func register_sfx(name: String, stream: AudioStream) -> void:
	sfx_library[name] = stream

func register_music(name: String, stream: AudioStream) -> void:
	music_library[name] = stream
