extends CharacterBody2D
class_name MachineCandidate

signal phase_changed(new_phase: int)
signal boss_defeated
signal resonance_window_opened
signal resonance_window_closed

enum Phase {
	PROPAGANDA_WALL,
	DRONE_BARRAGE,
	RESONANCE_CORE
}

@export var max_health: int = 50
@export var wall_move_speed: float = 80.0
@export var drone_spawn_interval: float = 1.5
@export var resonance_frequency: float = 2.0

var current_health: int
var current_phase: Phase = Phase.PROPAGANDA_WALL
var phase_timer: float = 0.0
var drone_timer: float = 0.0
var resonance_timer: float = 0.0
var resonance_window_open: bool = false
var resonance_hits_required: int = 3
var resonance_hits_current: int = 0
var truth_nodes: Array = []
var is_vulnerable: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@ontml:parameter>
<parameter name="health_bar: ProgressBar = $HealthBar
@onready var propaganda_wall: Node2D = $PropagandaWall
@onready var drone_spawn_points: Node2D = $DroneSpawnPoints
@onready var truth_node_container: Node2D = $TruthNodes

var propaganda_segment_scene: PackedScene = preload("res://scenes/bosses/PropagandaSegment.tscn")
var drone_scene: PackedScene = preload("res://scenes/bosses/Drone.tscn")

func _ready() -> void:
	add_to_group("boss")
	current_health = max_health
	update_health_bar()
	setup_truth_nodes()

func _physics_process(delta: float) -> void:
	phase_timer += delta

	match current_phase:
		Phase.PROPAGANDA_WALL:
			execute_propaganda_phase(delta)
		Phase.DRONE_BARRAGE:
			execute_drone_phase(delta)
		Phase.RESONANCE_CORE:
			execute_resonance_phase(delta)

	move_and_slide()

func execute_propaganda_phase(delta: float) -> void:
	if propaganda_wall and propaganda_wall.get_child_count() == 0:
		spawn_propaganda_wall()

	is_vulnerable = propaganda_wall.get_child_count() == 0

	if phase_timer >= 20.0 or is_vulnerable:
		advance_phase()

func execute_drone_phase(delta: float) -> void:
	drone_timer += delta

	if drone_timer >= drone_spawn_interval:
		spawn_drone()
		drone_timer = 0.0

	if phase_timer >= 25.0:
		advance_phase()

func execute_resonance_phase(delta: float) -> void:
	resonance_timer += delta

	var cycle_time: float = fmod(resonance_timer, resonance_frequency)
	var window_start: float = resonance_frequency * 0.3
	var window_end: float = resonance_frequency * 0.7

	if cycle_time >= window_start and cycle_time <= window_end:
		if not resonance_window_open:
			resonance_window_open = true
			is_vulnerable = true
			resonance_window_opened.emit()
			activate_truth_nodes()
	else:
		if resonance_window_open:
			resonance_window_open = false
			is_vulnerable = false
			resonance_window_closed.emit()
			deactivate_truth_nodes()

	if resonance_hits_current >= resonance_hits_required:
		die()

func spawn_propaganda_wall() -> void:
	if not propaganda_segment_scene:
		return

	var segment_count: int = 8
	for i in range(segment_count):
		var segment: Node2D = propaganda_segment_scene.instantiate()
		propaganda_wall.add_child(segment)
		segment.position = Vector2(i * 60 - 210, -150)
		segment.add_to_group("propaganda_segment")

		if segment.has_method("set_move_speed"):
			segment.set_move_speed(wall_move_speed)

func spawn_drone() -> void:
	if not drone_scene or not drone_spawn_points:
		return

	var spawn_points: Array = drone_spawn_points.get_children()
	if spawn_points.is_empty():
		return

	var spawn_point: Node2D = spawn_points[randi() % spawn_points.size()]
	var drone: Node2D = drone_scene.instantiate()
	get_parent().add_child(drone)
	drone.global_position = spawn_point.global_position

func setup_truth_nodes() -> void:
	if not truth_node_container:
		return

	for i in range(4):
		var node: Area2D = create_truth_node()
		truth_node_container.add_child(node)
		var angle: float = (TAU / 4) * i + PI / 4
		node.position = Vector2(cos(angle), sin(angle)) * 100
		truth_nodes.append(node)

func create_truth_node() -> Area2D:
	var node: Area2D = Area2D.new()
	node.collision_layer = 32
	node.collision_mask = 16

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 15.0
	collision.shape = shape
	node.add_child(collision)

	var sprite_node: Sprite2D = Sprite2D.new()
	var placeholder: PlaceholderTexture2D = PlaceholderTexture2D.new()
	placeholder.size = Vector2(30, 30)
	sprite_node.texture = placeholder
	sprite_node.modulate = Color(0.5, 0.5, 0.5, 0.5)
	node.add_child(sprite_node)

	node.add_to_group("truth_node")
	node.body_entered.connect(_on_truth_node_hit.bind(node))

	return node

func activate_truth_nodes() -> void:
	for node in truth_nodes:
		if is_instance_valid(node) and node.get_child_count() > 0:
			var sprite_node: Node = node.get_child(1)
			if sprite_node is Sprite2D:
				sprite_node.modulate = Color(0.3, 1.0, 0.6, 1.0)

func deactivate_truth_nodes() -> void:
	for node in truth_nodes:
		if is_instance_valid(node) and node.get_child_count() > 0:
			var sprite_node: Node = node.get_child(1)
			if sprite_node is Sprite2D:
				sprite_node.modulate = Color(0.5, 0.5, 0.5, 0.5)

func _on_truth_node_hit(body: Node, node: Area2D) -> void:
	if not resonance_window_open:
		return

	if body.has_method("get_class") and body.get_class() == "Shockwave":
		resonance_hits_current += 1
		AudioManager.play_sfx("resonance_hit")

		if node in truth_nodes:
			truth_nodes.erase(node)
			node.queue_free()

func take_damage(amount: int) -> void:
	if not is_vulnerable:
		return

	current_health -= amount
	update_health_bar()
	flash_damage()

	if current_health <= 0 and current_phase != Phase.RESONANCE_CORE:
		advance_phase()

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
		Phase.PROPAGANDA_WALL:
			current_phase = Phase.DRONE_BARRAGE
		Phase.DRONE_BARRAGE:
			current_phase = Phase.RESONANCE_CORE
			resonance_timer = 0.0

	phase_changed.emit(current_phase)

func die() -> void:
	boss_defeated.emit()
	GameManager.add_score(5000)
	AudioManager.play_sfx("boss_die")
	queue_free()
