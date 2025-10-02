extends Area2D
class_name Shockwave

@export var base_radius: float = 150.0
@export var expansion_speed: float = 400.0
@export var lifetime: float = 0.8
@export var push_force: float = 500.0
@export var waveform_segments: int = 24

var power_multiplier: float = 1.0
var current_radius: float = 0.0
var age: float = 0.0
var affected_bodies: Array = []

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var circle_shape: CircleShape2D = CircleShape2D.new()

func _ready() -> void:
	collision_shape.shape = circle_shape
	collision_layer = 0
	collision_mask = 30
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func initialize(start_pos: Vector2, power: float) -> void:
	global_position = start_pos
	power_multiplier = power
	current_radius = 10.0
	circle_shape.radius = current_radius
	draw_waveform()

func _physics_process(delta: float) -> void:
	age += delta
	current_radius += expansion_speed * power_multiplier * delta
	circle_shape.radius = current_radius

	var alpha: float = 1.0 - (age / lifetime)
	modulate.a = alpha

	if age >= lifetime:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	draw_waveform()

func draw_waveform() -> void:
	var points: PackedVector2Array = []
	var angle_step: float = TAU / waveform_segments

	for i in range(waveform_segments + 1):
		var angle: float = i * angle_step
		var wave_offset: float = sin(angle * 3.0 + age * 10.0) * 8.0 * power_multiplier
		var radius: float = current_radius + wave_offset
		var point: Vector2 = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)

	if visual and visual is Node2D:
		visual.queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body in affected_bodies:
		return

	affected_bodies.append(body)

	if body.has_method("apply_shockwave"):
		var direction: Vector2 = (body.global_position - global_position).normalized()
		body.apply_shockwave(direction, push_force * power_multiplier)

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(int(power_multiplier))

	if body.is_in_group("destructible"):
		if body.has_method("destroy"):
			body.destroy()

	if body.is_in_group("platform") and power_multiplier >= 1.5:
		if body.has_method("activate"):
			body.activate()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("collectible"):
		if area.has_method("attract_to"):
			var player: Node = get_tree().get_first_node_in_group("player")
			if player:
				area.attract_to(player.global_position)
