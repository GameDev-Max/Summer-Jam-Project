extends CharacterBody2D

@export var speed: float = 150.0
@export var travel_distance: float = 500.0
@export var direction: int = 1 # "Left" or "Right"

var _start_position: Vector2
var _distance_travelled: float = 0.0
var moving: bool = false

var _last_position := Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var HurtboxCol: CollisionShape2D = $Hurtbox/CollisionShape2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	HurtboxCol.disabled = true
	
	_start_position = global_position
	if direction == -1:
		anim.flip_h = true
	else:
		anim.flip_h = false
		
	anim.play("Warn")
	await get_tree().create_timer(2.0).timeout
	anim.play("Rise")
	await get_tree().create_timer(1.0).timeout
	anim.play("Idle")
	moving = true
	HurtboxCol.disabled = false

func _physics_process(delta: float) -> void:
	
	var to_player := (player.global_position - global_position).normalized()
	anim.flip_h = to_player.x < 0
	
	if moving:
		

		# Move toward player
		velocity = to_player * speed
		move_and_slide()

		# Add the actual movement distance this frame
		var frame_distance = global_position.distance_to(_last_position)
		_distance_travelled += frame_distance
		_last_position = global_position
		if _distance_travelled >= travel_distance:
			moving = false
			velocity = Vector2.ZERO
			anim.play("Sink")
			HurtboxCol.disabled = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
