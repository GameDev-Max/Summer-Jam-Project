extends CharacterBody2D

@export var arc_duration: float = 0.75
@export var arc_height_max: float = 100.0
@export var arc_height_min: float = 30.0

@onready var main: Sprite2D = $Ball
@onready var shadow: Sprite2D = $Shadow
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var main_shape: CollisionShape2D = $CollisionShape2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")

var origin: Vector2
var target: Vector2
var timer: float = 0.0
var traveling := false
var arc_height := 50.0

func _ready():
	shoot(player.global_position)

func _physics_process(delta: float) -> void:
	main.rotate(360*delta)
	
	if traveling:
		timer += delta
		var t: float = clamp(timer / arc_duration, 0.0, 1.0)

		# Lerp flat position
		var flat_pos := origin.lerp(target, t)
		var arc_offset := -sin(t * PI) * arc_height

		global_position = flat_pos
		position.y += arc_offset

		# Update shadow (constant flat position)
		shadow.global_position = target

		if t >= 1.0:
			land()

func shoot(landing_point: Vector2) -> void:
	origin = global_position
	target = landing_point

	var dist := origin.distance_to(target)
	arc_height = clamp(arc_height_max - dist * 0.5, arc_height_min, arc_height_max)

	timer = 0.0
	traveling = true

	# Disable hitbox while flying
	hurtbox_shape.disabled = true
	if main_shape:
		main_shape.disabled = true

func land() -> void:
	traveling = false
	global_position = target

	# Re-enable collisions
	hurtbox_shape.disabled = false
	if main_shape:
		main_shape.disabled = false
	
	queue_free()
