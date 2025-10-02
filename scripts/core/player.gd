extends CharacterBody2D
class_name Player

signal voice_collected(type: String)
signal shockwave_fired(position: Vector2, power: float)
signal player_died
signal honesty_blast_ready(ready: bool)

@export var move_speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var max_fall_speed: float = 800.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0
@export var air_acceleration: float = 1200.0
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var voices_collected: int = 0
var collectible_stage: int = 0
var honesty_streak: int = 0
var shockwave_charge: float = 0.0
var max_shockwave_charge: float = 2.0
var is_charging_shockwave: bool = false
var can_double_jump: bool = false
var has_double_jumped: bool = false

var time_since_grounded: float = 0.0
var jump_buffer: float = 0.0
var facing_direction: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shockwave_spawn: Marker2D = $ShockwaveSpawn
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	handle_input(delta)
	apply_movement(delta)
	update_animations()
	move_and_slide()

	if is_on_floor():
		time_since_grounded = 0.0
		has_double_jumped = false
	else:
		time_since_grounded += delta

	if jump_buffer > 0.0:
		jump_buffer -= delta

func handle_input(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_time

	if jump_buffer > 0.0 and (is_on_floor() or time_since_grounded < coyote_time):
		perform_jump()
		jump_buffer = 0.0
	elif jump_buffer > 0.0 and can_double_jump and not has_double_jumped:
		perform_jump()
		has_double_jumped = true
		jump_buffer = 0.0

	if Input.is_action_pressed("shockwave"):
		is_charging_shockwave = true
		shockwave_charge = min(shockwave_charge + delta, max_shockwave_charge)
		honesty_blast_ready.emit(shockwave_charge >= max_shockwave_charge)

	if Input.is_action_just_released("shockwave") and is_charging_shockwave:
		fire_shockwave()
		is_charging_shockwave = false
		shockwave_charge = 0.0
		honesty_blast_ready.emit(false)

func perform_jump() -> void:
	velocity.y = jump_velocity
	AudioManager.play_sfx("jump")

func fire_shockwave() -> void:
	var power: float = 1.0 + (shockwave_charge / max_shockwave_charge)
	var spawn_pos: Vector2 = shockwave_spawn.global_position if shockwave_spawn else global_position

	shockwave_fired.emit(spawn_pos, power)
	AudioManager.play_sfx("shockwave")

	if power >= 1.8:
		honesty_streak += 1

func apply_movement(delta: float) -> void:
	var input_direction: float = Input.get_axis("move_left", "move_right")

	if input_direction != 0:
		facing_direction = int(sign(input_direction))
		sprite.flip_h = facing_direction < 0

	if is_on_floor():
		if input_direction != 0:
			velocity.x = move_toward(velocity.x, input_direction * move_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		if input_direction != 0:
			velocity.x = move_toward(velocity.x, input_direction * move_speed, air_acceleration * delta)

	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)

func update_animations() -> void:
	if not animation_player:
		return

	if is_charging_shockwave:
		animation_player.play("charge")
	elif not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		else:
			animation_player.play("fall")
	elif abs(velocity.x) > 10:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func collect_voice(type: String) -> void:
	voices_collected += 1
	voice_collected.emit(type)
	AudioManager.play_sfx("collect")

	if voices_collected >= 10 and collectible_stage < 1:
		collectible_stage = 1
	elif voices_collected >= 25 and collectible_stage < 2:
		collectible_stage = 2
		can_double_jump = true
	elif voices_collected >= 50 and collectible_stage < 3:
		collectible_stage = 3

func take_damage(amount: int = 1) -> void:
	player_died.emit()
	AudioManager.play_sfx("death")
	queue_free()

func get_collectible_stage() -> int:
	return collectible_stage

func get_voices_count() -> int:
	return voices_collected

func get_honesty_streak() -> int:
	return honesty_streak
