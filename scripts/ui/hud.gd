extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var voices_label: Label = $VoicesLabel
@onready var time_label: Label = $TimeLabel
@onready var charge_bar: ProgressBar = $ChargeBar
@onready var honesty_indicator: Label = $HonestyIndicator

var player: Player = null

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)

	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player:
		player.honesty_blast_ready.connect(_on_honesty_blast_ready)

	update_displays()

func _process(delta: float) -> void:
	update_displays()

func update_displays() -> void:
	if score_label:
		score_label.text = "Score: " + str(GameManager.current_score)

	if player:
		if voices_label:
			voices_label.text = "Voices: " + str(player.get_voices_count())

		if charge_bar:
			charge_bar.value = (player.shockwave_charge / player.max_shockwave_charge) * 100.0

	var level: Node = get_parent()
	if level and level.has_method("get_time_remaining"):
		var time_remaining: float = level.get_time_remaining()
		if time_label and time_remaining > 0:
			var minutes: int = int(time_remaining) / 60
			var seconds: int = int(time_remaining) % 60
			time_label.text = "Time: %02d:%02d" % [minutes, seconds]
		elif time_label:
			time_label.text = ""

func _on_score_changed(new_score: int) -> void:
	update_displays()

func _on_honesty_blast_ready(ready: bool) -> void:
	if honesty_indicator:
		honesty_indicator.visible = ready
