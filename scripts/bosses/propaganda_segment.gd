extends StaticBody2D

@export var health: int = 2
var move_speed: float = 80.0
var direction: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("propaganda_segment")

func _physics_process(delta: float) -> void:
	position.y += move_speed * direction * delta

	if position.y > 200:
		direction = -1
	elif position.y < -200:
		direction = 1

func set_move_speed(speed: float) -> void:
	move_speed = speed

func take_damage(amount: int) -> void:
	health -= amount

	if sprite:
		sprite.modulate = Color(1, 0.7, 0.7)
		await get_tree().create_timer(0.1).timeout
		if sprite:
			sprite.modulate = Color(1, 1, 1)

	if health <= 0:
		queue_free()
