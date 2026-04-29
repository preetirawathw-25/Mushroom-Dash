extends CharacterBody2D

# Movement Settings
@export var patrol_speed := 40.0
@export var chase_speed := 70.0
@export var patrol_distance := 100.0

# Combat Settings
@export var attack_cooldown := 0.5
@export var attack_damage := 1

# Physics Settings
@export var gravity := 500.0
@export var max_fall_speed := 200.0

# State Variables
var start_position: Vector2
var moving_right := true
var is_dead := false
var can_attack := true
var player: Node2D = null
var player_detected := false
var player_in_range := false
var is_attacking := false  # New state to track attack animation

func _ready():
	start_position = global_position
	_connect_signals()
	$AnimatedSprite2D.play("walk")

func _connect_signals():
	$DetectionArea.body_entered.connect(_on_detection_entered)
	$DetectionArea.body_exited.connect(_on_detection_exited)
	$AttackRange.body_entered.connect(_on_attack_entered)
	$AttackRange.body_exited.connect(_on_attack_exited)
	$AttackCooldownTimer.timeout.connect(_on_attack_cooldown_timeout)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if is_dead:
		return
	
	_apply_gravity(delta)
	
	# Completely stop movement during attack
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	
	# Only move if not attacking
	if player_in_range and can_attack and player_detected:
		attack()
	else:
		_handle_movement(delta)
	
	move_and_slide()
	_update_sprite_direction()

func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
	else:
		velocity.y = 0

func _handle_movement(delta):
	if player_detected and player:
		chase_player()
	else:
		patrol()

func _update_sprite_direction():
	if player:
		$AnimatedSprite2D.flip_h = player.global_position.x < global_position.x
	else:
		if velocity.x != 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0

func patrol():
	var target_x = start_position.x + (patrol_distance if moving_right else -patrol_distance)
	var direction = sign(target_x - global_position.x)
	velocity.x = direction * patrol_speed
	
	if abs(global_position.x - target_x) < 5.0:
		moving_right = !moving_right

func chase_player():
	if !player:
		return
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * chase_speed

func attack():
	if !can_attack or !player or is_attacking:
		return
	
	can_attack = false
	is_attacking = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("hit")
	$AttackCooldownTimer.start(attack_cooldown)
	
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)

func die():
	is_dead = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("die")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	$DetectionArea.monitoring = false
	$AttackRange.monitoring = false

# Signal Handlers
func _on_detection_entered(body):
	if body.name == "Player":
		player_detected = true
		player = body

func _on_detection_exited(body):
	if body == player:
		player_detected = false
		player = null

func _on_attack_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_attack_exited(body):
	if body.name == "Player":
		player_in_range = false

func _on_attack_cooldown_timeout():
	can_attack = true

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "hit":
		is_attacking = false
		if not is_dead:
			$AnimatedSprite2D.play("walk")
