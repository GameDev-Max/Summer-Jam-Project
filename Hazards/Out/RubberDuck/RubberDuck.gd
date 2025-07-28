extends CharacterBody2D

@export var speed: float = 150.0
@export var travel_distance: float = 300.0
@export var direction: int = 1 # "Left" or "Right"

var _start_position: Vector2
var _distance_travelled: float = 0.0
var moving: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var HurtboxCol: CollisionShape2D = $Hurtbox/CollisionShape2D

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
	if moving:
		velocity = Vector2(speed * direction, 0)
		move_and_slide()

		_distance_travelled = abs(global_position.x - _start_position.x)
		if _distance_travelled >= travel_distance:
			moving = false
			velocity = Vector2.ZERO
			anim.play("Sink")
			HurtboxCol.disabled = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
