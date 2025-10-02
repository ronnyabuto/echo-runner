extends CharacterBody2D
class_name LobbyistBoss

signal phase_changed(new_phase: int)
signal boss_defeated

enum Phase {
	CASH_RAIN,
	INFLUENCE_SHIELDS,
	BRIBED_MINIONS
}

@export var max_health: int = 30
@export var move_speed: float = 150.0
@export var cash_spawn_interval: float = 0.5
@export var shield_count: int = 8
@export var minion_spawn_count: int = 4

var current_health: int
var current_phase: Phase = Phase.CASH_RAIN
var phase_timer: float = 0.0
var cash_timer: float = 0.0
var is_vulnerable: bool = true
var shields: Array = []
var spawned_minions: Array = []
var arena_center: Vector2
var movement_target: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var shield_container: Node2D = $ShieldContainer
@onready var minion_spawn_points: Node2D = $MinionSpawnPoints

var cash_projectile_scene: PackedScene = preload("res://scenes/bosses/CashProjectile.tscn")
var bribed_minion_scene: PackedScene = preload("res://scenes/enemies/BaseEnemy.tscn")

func _ready() -> void:
	add_to_group("boss")
	current_health = max_health
	arena_center = global_position
	movement_target = arena_center
	update_health_bar()

func _physics_process(delta: float) -> void:
	phase_timer += delta

	match current_phase:
		Phase.CASH_RAIN:
			execute_cash_rain_phase(delta)
		Phase.INFLUENCE_SHIELDS:
			execute_shield_phase(delta)
		Phase.BRIBED_MINIONS:
			execute_minion_phase(delta)

	move_boss(delta)
	move_and_slide()

func execute_cash_rain_phase(delta: float) -> void:
	cash_timer += delta

	if cash_timer >= cash_spawn_interval:
		spawn_cash_projectile()
		cash_timer = 0.0

	if phase_timer >= 15.0:
		advance_phase()

func execute_shield_phase(delta: float) -> void:
	if shields.is_empty():
		spawn_shields()

	is_vulnerable = shields.is_empty()

	if phase_timer >= 20.0 or shields.is_empty():
		advance_phase()

func execute_minion_phase(delta: float) -> void:
	if spawned_minions.is_empty() and phase_timer < 1.0:
		spawn_minions()

	spawned_minions = spawned_minions.filter(func(m): return is_instance_valid(m))

	if spawned_minions.is_empty() and phase_timer >= 2.0:
		advance_phase()

func spawn_cash_projectile() -> void:
	if not cash_projectile_scene:
		return

	var projectile: Node2D = cash_projectile_scene.instantiate()
	get_parent().add_child(projectile)

	var player: Node = get_tree().get_first_node_in_group("player")
	var target_pos: Vector2 = player.global_position if player else arena_center

	projectile.global_position = global_position + Vector2(randf_range(-50, 50), -100)

	if projectile.has_method("set_target"):
		projectile.set_target(target_pos)

func spawn_shields() -> void:
	for i in range(shield_count):
		var angle: float = (TAU / shield_count) * i
		var shield: Area2D = create_shield_bubble(angle)
		shield_container.add_child(shield)
		shields.append(shield)

func create_shield_bubble(angle: float) -> Area2D:
	var shield: Area2D = Area2D.new()
	shield.collision_layer = 32
	shield.collision_mask = 16

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 20.0
	collision.shape = shape
	shield.add_child(collision)

	var sprite_node: Sprite2D = Sprite2D.new()
	var placeholder: PlaceholderTexture2D = PlaceholderTexture2D.new()
	placeholder.size = Vector2(40, 40)
	sprite_node.texture = placeholder
	sprite_node.modulate = Color(0.8, 0.6, 1.0, 0.7)
	shield.add_child(sprite_node)

	var radius: float = 120.0
	shield.position = Vector2(cos(angle), sin(angle)) * radius

	shield.add_to_group("boss_shield")
	shield.body_entered.connect(_on_shield_hit.bind(shield))

	return shield

func _on_shield_hit(body: Node, shield: Area2D) -> void:
	if body.is_in_group("player"):
		var shockwave_group: Array = get_tree().get_nodes_in_group("shockwave")
		if not shockwave_group.is_empty():
			destroy_shield(shield)

func destroy_shield(shield: Area2D) -> void:
	if shield in shields:
		shields.erase(shield)
		shield.queue_free()
		AudioManager.play_sfx("shield_break")

func spawn_minions() -> void:
	if not minion_spawn_points:
		return

	var spawn_points: Array = minion_spawn_points.get_children()
	for i in range(min(minion_spawn_count, spawn_points.size())):
		if bribed_minion_scene:
			var minion: Node2D = bribed_minion_scene.instantiate()
			get_parent().add_child(minion)
			minion.global_position = spawn_points[i].global_position
			minion.add_to_group("bribed_minion")
			spawned_minions.append(minion)

func move_boss(delta: float) -> void:
	var direction: Vector2 = (movement_target - global_position).normalized()
	velocity = direction * move_speed

	if global_position.distance_to(movement_target) < 50.0:
		var player: Node = get_tree().get_first_node_in_group("player")
		if player:
			var offset: Vector2 = Vector2(randf_range(-200, 200), randf_range(-100, 100))
			movement_target = arena_center + offset

func take_damage(amount: int) -> void:
	if not is_vulnerable:
		return

	current_health -= amount
	update_health_bar()
	flash_damage()

	if current_health <= 0:
		die()

func flash_damage() -> void:
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		if sprite:
			sprite.modulate = Color(1, 1, 1)

func update_health_bar() -> void:
	if health_bar:
		health_bar.value = (float(current_health) / float(max_health)) * 100.0

func advance_phase() -> void:
	phase_timer = 0.0

	match current_phase:
		Phase.CASH_RAIN:
			current_phase = Phase.INFLUENCE_SHIELDS
		Phase.INFLUENCE_SHIELDS:
			current_phase = Phase.BRIBED_MINIONS
		Phase.BRIBED_MINIONS:
			current_phase = Phase.CASH_RAIN

	phase_changed.emit(current_phase)

func die() -> void:
	boss_defeated.emit()
	GameManager.add_score(1000)
	AudioManager.play_sfx("boss_die")
	queue_free()
