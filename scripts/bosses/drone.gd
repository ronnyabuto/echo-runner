extends CharacterBody2D

@export var move_speed: float = 150.0
@export var health: int = 2
@export var shoot_interval: float = 2.0

var shoot_timer: float = 0.0
var target: Node = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("drone")
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	shoot_timer += delta

	if target and is_instance_valid(target):
		var direction: Vector2 = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if shoot_timer >= shoot_interval:
		shoot()
		shoot_timer = 0.0

func shoot() -> void:
	AudioManager.play_sfx("drone_shoot")

func take_damage(amount: int) -> void:
	health -= amount

	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		if sprite:
			sprite.modulate = Color(1, 1, 1)

	if health <= 0:
		queue_free()
