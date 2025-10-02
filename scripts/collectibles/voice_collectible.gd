extends Area2D
class_name VoiceCollectible

enum VoiceType {
	FLYER,
	VOTE,
	VIRAL_CLIP,
	CROWD_ECHO
}

@export var voice_type: VoiceType = VoiceType.FLYER
@export var float_amplitude: float = 10.0
@export var float_speed: float = 2.0
@export var attraction_speed: float = 300.0

var is_attracted: bool = false
var attraction_target: Vector2 = Vector2.ZERO
var start_y: float = 0.0
var time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("collectible")
	start_y = global_position.y
	body_entered.connect(_on_body_entered)
	update_visual()

func _physics_process(delta: float) -> void:
	time += delta

	if is_attracted:
		var direction: Vector2 = (attraction_target - global_position).normalized()
		global_position += direction * attraction_speed * delta

		if global_position.distance_to(attraction_target) < 20.0:
			collect()
	else:
		global_position.y = start_y + sin(time * float_speed) * float_amplitude

func update_visual() -> void:
	if not sprite:
		return

	match voice_type:
		VoiceType.FLYER:
			sprite.modulate = Color(0.8, 0.9, 1.0)
		VoiceType.VOTE:
			sprite.modulate = Color(1.0, 0.8, 0.3)
		VoiceType.VIRAL_CLIP:
			sprite.modulate = Color(1.0, 0.4, 0.7)
		VoiceType.CROWD_ECHO:
			sprite.modulate = Color(0.6, 1.0, 0.6)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect()

func attract_to(target_pos: Vector2) -> void:
	is_attracted = true
	attraction_target = target_pos

func collect() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_method("collect_voice"):
		var type_name: String = VoiceType.keys()[voice_type]
		player.collect_voice(type_name)

	GameManager.add_score(10 * (int(voice_type) + 1))
	queue_free()

func get_voice_type() -> VoiceType:
	return voice_type
