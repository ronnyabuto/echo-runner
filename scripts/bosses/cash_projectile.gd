extends Area2D

@export var speed: float = 200.0
@export var damage: int = 1

var velocity: Vector2 = Vector2.DOWN
var target_position: Vector2

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func set_target(target: Vector2) -> void:
	target_position = target
	var direction: Vector2 = (target - global_position).normalized()
	velocity = direction * speed

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.collision_layer & 8:
		queue_free()
