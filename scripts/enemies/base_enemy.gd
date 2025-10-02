extends CharacterBody2D
class_name BaseEnemy

signal enemy_died(score_value: int)

@export var max_health: int = 3
@export var move_speed: float = 100.0
@export var patrol_distance: float = 200.0
@export var detection_range: float = 300.0
@export var score_value: int = 50
@export var damage_to_player: int = 1

var current_health: int
var patrol_start: Vector2
var patrol_direction: int = 1
var is_flipped: bool = false
var is_stunned: bool = false
var stun_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var wall_detector: RayCast2D = $WallDetector
@onready var floor_detector: RayCast2D = $FloorDetector

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	patrol_start = global_position

	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)

func _physics_process(delta: float) -> void:
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
		apply_gravity(delta)
		move_and_slide()
		return

	ai_behavior(delta)
	apply_gravity(delta)
	move_and_slide()
	update_sprite_direction()

func ai_behavior(delta: float) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")

	if player and global_position.distance_to(player.global_position) < detection_range:
		chase_player(player, delta)
	else:
		patrol(delta)

func patrol(delta: float) -> void:
	velocity.x = patrol_direction * move_speed

	if wall_detector and wall_detector.is_colliding():
		patrol_direction *= -1

	if floor_detector and not floor_detector.is_colliding():
		patrol_direction *= -1

	var distance_from_start: float = abs(global_position.x - patrol_start.x)
	if distance_from_start > patrol_distance:
		patrol_direction *= -1

func chase_player(player: Node, delta: float) -> void:
	var direction: float = sign(player.global_position.x - global_position.x)
	velocity.x = direction * move_speed * 1.5

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func update_sprite_direction() -> void:
	if sprite:
		if velocity.x < 0 and not is_flipped:
			sprite.flip_h = true
			is_flipped = true
		elif velocity.x > 0 and is_flipped:
			sprite.flip_h = false
			is_flipped = false

func take_damage(amount: int) -> void:
	current_health -= amount
	flash_damage()

	if current_health <= 0:
		die()

func flash_damage() -> void:
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		if sprite:
			sprite.modulate = Color(1, 1, 1)

func apply_shockwave(direction: Vector2, force: float) -> void:
	velocity = direction * force
	is_stunned = true
	stun_timer = 0.5
	AudioManager.play_sfx("enemy_hit")

func die() -> void:
	enemy_died.emit(score_value)
	GameManager.add_score(score_value)
	AudioManager.play_sfx("enemy_die")
	queue_free()

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage_to_player)
