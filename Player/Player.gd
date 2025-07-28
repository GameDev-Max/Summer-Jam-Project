extends CharacterBody2D

# --- CONFIGURABLE VARIABLES ---

@export var move_speed := 200.0     # Regular movement speed
@export var dash_speed := 1250.0     # Speed during dash
@export var dash_duration := 0.2    # How long dash lasts in seconds

# --- INTERNAL STATE ---
var dash_vector := Vector2.ZERO     # Direction to dash in
var is_dashing := false             # Are we currently dashing?
var dash_time_elapsed := 0.0

var can_dash := true
var dash_cooldown := 0.0

# --- NODE REFERENCES ---
@onready var heart_bar := $UI/HealthBar
@onready var anim_sprite := $AnimatedSprite2D
@onready var dash_timer := $DashTimer
@onready var invuln_timer := $InvulnTimer

@onready var Splash := $Splash

var knockback_time := 0.2		# Duration in seconds
var knockback_vector := Vector2.ZERO
var is_knocked_back := false
var knockback_timer := 0.0
const KNOCKBACK_DURATION := 0.2
const KNOCKBACK_FORCE := 400.0

var MaxHealth = 6
var CurrentHealth = MaxHealth

var invulnerable := false  # can be referenced externally
var dead := false

func _ready():
	create_hearts()
	update_heart_display()

func update_heart_display():
	for i in range(MaxHealth / 2):
		var heart_node = heart_bar.get_node("Heart%d" % (i + 1))
		var heart_hp = clamp(CurrentHealth - i * 2, 0, 2)

		match heart_hp:
			2:
				heart_node.play("Full")
			1:
				heart_node.play("Half")
			0:
				heart_node.play("None")

func create_hearts():
	for i in range(MaxHealth / 2):
		var heart = preload("res://Player/Heart.tscn").instantiate()
		heart.name = "Heart%d" % (i + 1)
		heart.position = Vector2(55 + i * 75, 55)  # 55 pixels apart
		heart_bar.add_child(heart)


func _physics_process(delta):
	if dead:
		return
	
	if dash_cooldown > 0.0:
		dash_cooldown -= delta
		can_dash = false
	else:
		can_dash = true
		
	if is_knocked_back:
		velocity = knockback_vector
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
	else:
		var input_vector = Vector2(
			Input.get_action_strength("Right") - Input.get_action_strength("Left"),
			Input.get_action_strength("Down") - Input.get_action_strength("Up")
		).normalized()

		if is_dashing:
			dash_time_elapsed += delta
			var t := dash_time_elapsed / dash_duration
			t = clamp(t, 0.0, 1.0)
			var eased_speed := dash_speed * sin(t * PI)
			velocity = dash_vector * eased_speed
			if t >= 1.0:
				is_dashing = false
				velocity = Vector2.ZERO
		else:
			velocity = input_vector * move_speed

			if Input.is_action_just_pressed("Dive"):
				start_dash()
		if is_dashing:
			anim_sprite.play("Dive")
		elif velocity.length() > 0:
			anim_sprite.play("Idle")
		else:
			anim_sprite.play("Idle")

		# --- Flip sprite left/right ---
		var to_mouse = get_global_mouse_position() - global_position
		anim_sprite.flip_h = to_mouse.x < 0
		
		# Check for overlapping hazards (only if not invulnerable)
		if not invulnerable:
			var collisions = get_overlapping_hazards()
			for hazard in collisions:
				apply_hazard_damage(hazard.position)
				break # only one hazard hit per frame
	move_and_slide()


# Starts a dash in the given direction
func start_dash():
	if can_dash == false:
		return
	Splash.restart()
	dash_vector = (get_global_mouse_position() - global_position).normalized()
	dash_time_elapsed = 0.0
	dash_cooldown = 0.5
	is_dashing = true
	invulnerable = true
	invuln_timer.start(0.1)

func _on_dash_timer_timeout():
	if is_knocked_back:
		is_knocked_back = false
	else:
		is_dashing = false
		invuln_timer.start(0.4)

func _on_invuln_timer_timeout():
	invulnerable = false

func get_overlapping_hazards() -> Array:
	var space_state = get_world_2d().direct_space_state
	var result = []
	var shape = $CollisionShape2D.shape.duplicate()
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var collisions = space_state.intersect_shape(query, 10)
	for hit in collisions:
		if hit.collider.is_in_group("Hazard"):
			result.append(hit.collider)
	return result


func apply_hazard_damage(hazard_pos: Vector2):
	take_damage(1)
	invulnerable = true
	invuln_timer.start(1.0)

	# Compute knockback direction (from hazard to player → reversed)
	var direction = (position - hazard_pos).normalized()
	knockback_vector = direction * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_DURATION
	is_knocked_back = true

func take_damage(amount := 1):
	if invulnerable:
		return
	CurrentHealth -= amount
	update_heart_display()

	if CurrentHealth <= 0:
		die()
	else:
		invulnerable = true
		invuln_timer.start(1.0)

func die():
	invulnerable = true
	if dead:
		return
	dead = true
	
	var camera := $Camera2D
	var tween := create_tween()
	tween.tween_property(camera, "zoom", Vector2(500, 500), 2.5).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
	camera.zoom = Vector2(2, 2)

func _process(delta: float) -> void:
	if dead:
		return
	
	
	var mouse_pos: Vector2 = get_global_mouse_position()
