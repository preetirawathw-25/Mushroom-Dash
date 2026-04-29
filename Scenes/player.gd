extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
signal life_changed(lives: int)
signal mushroom_collected(count: int)
var walk_speed = 200
var run_speed = 350
var jump_strength = 400
var gravity = 800
var is_dead = false
var run_timer_right = 0.0
var run_timer_left = 0.0
var run_threshold = 2.0  # Seconds to start running
signal died
var is_attacking = false
var mushroom_count = 0  # ← Track collected mushrooms
var is_hurt = false
var lives = 3
var is_invincible = false
@onready var footstep_player = $FootstepPlayer
var footstep_delay = 0.3  # Time between footsteps
var footstep_timer = 0.0
@onready var jump_sound = $JumpPlayer

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	# Load footstep sound
	var footstep_sound = load("res://assets/sound/footsteps.ogg")
	# Configure audio player
	footstep_player.stream = footstep_sound
	footstep_player.volume_db = -25  # Adjust volume as needed
	footstep_player.bus = "SFX"  # Make sure you have an SFX audio bus
	jump_sound.stream = load("res://assets/sound/Jump2.ogg")
	

func _on_animation_finished():
	if anim.animation == "hurt":
		is_hurt = false
		_play_animation()
		
func take_damage(damage: int):
	if is_invincible or is_dead:
		return

	lives -= damage
	emit_signal("life_changed", lives)  # 👈 Emit signal to parent scene
	is_hurt = true
	print("Player hit! Lives left:", lives)
	anim.play("hurt")

	if lives <= 0:
		die()
	else:
		become_invincible()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("die")
	print("Player died!")
	emit_signal("died")  # 👈 emit first
	set_process(false)
	set_physics_process(false)

func become_invincible():
	is_invincible = true
	modulate = Color(1, 1, 1, 0.5)  # Half transparent as visual feedback

	# Use a timer to end invincibility
	var invincibility_timer = Timer.new()
	invincibility_timer.wait_time = 0.8  # 1.5 seconds of invincibility
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_end_invincibility)
	add_child(invincibility_timer)
	invincibility_timer.start()

func _end_invincibility():
	is_invincible = false
	modulate = Color(1, 1, 1, 1)  # Restore full opacity
	
func _physics_process(delta):
	# Reset horizontal velocity
	velocity.x = 0

	# Horizontal movement and run timers
	if Input.is_key_pressed(KEY_D):
		run_timer_right += delta
		run_timer_left = 0.0
		velocity.x = run_speed if run_timer_right >= run_threshold else walk_speed
	elif Input.is_key_pressed(KEY_A):
		run_timer_left += delta
		run_timer_right = 0.0
		velocity.x = -run_speed if run_timer_left >= run_threshold else -walk_speed
	else:
		run_timer_right = 0.0
		run_timer_left = 0.0

	# Jumping
	if is_on_floor() and Input.is_key_pressed(KEY_W):
		velocity.y = -jump_strength
		jump_sound.pitch_scale = randf_range(0.95, 1.05)
		jump_sound.play()

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if is_on_floor() and abs(velocity.x) > 10:
		
		footstep_timer += delta
		
		if footstep_timer >= footstep_delay:
			
			footstep_player.pitch_scale = randf_range(0.9, 1.1)  # Slight pitch variation
			
			footstep_player.play()
			
			footstep_timer = 0.0
	
	else:
		
		footstep_timer = 0.0
		
		if footstep_player.playing:
			
			footstep_player.stop()
	# Move with proper up_direction for walking over bumps
	move_and_slide()

	# Check for attack
	is_attacking = Input.is_key_pressed(KEY_SPACE)

	# Play appropriate animation
	_play_animation()

func _play_animation():
	if is_dead:
		return  # Don't override death animation
	if is_hurt:
		return  # Don't override hurt animation
	if is_attacking:
		anim.play("attack")
	elif not is_on_floor():
		anim.play("jump")
	elif abs(velocity.x) > 0:
		var running = (run_timer_right >= run_threshold or run_timer_left >= run_threshold)
		anim.play("run" if running else "walk")
	else:
		anim.play("idle")

	# Flip character
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0

func collect_mushroom(value: int):
	mushroom_count += value
	emit_signal("mushroom_collected", mushroom_count)
	print("Collected mushrooms: ", mushroom_count)

func respawn_near_river():
	if is_dead:
		return

	if lives <= 1:
		die()
		lives = 0
		emit_signal("life_changed", lives)
		await get_tree().process_frame  # Let the heart disappear visually

	else:
		take_damage(1)
		position = Vector2(1200, 100)
		velocity = Vector2.ZERO

func respawn_near_river1():
	if is_dead:
		return

	if lives <= 1:
		die()
		lives = 0
		emit_signal("life_changed", lives)
		await get_tree().process_frame  # Let the heart disappear visually

	else:
		take_damage(1)
		position = Vector2(3000, 100)
		velocity = Vector2.ZERO

func respawn_near_river2():
	if is_dead:
		return

	if lives <= 1:
		die()
		lives = 0
		emit_signal("life_changed", lives)
		await get_tree().process_frame  # Let the heart disappear visually

	else:
		take_damage(1)
		position = Vector2(6000, 100)
		velocity = Vector2.ZERO
	
func play_death_animation() -> void:
	anim.play("die")  # Replace "death" with your animation name
	await anim.animation_finished

func reset_player():
	# Reset player state
	lives = 3  # Reset the lives
	mushroom_count = 0  # Reset mushroom count
	is_dead = false  # Reset death state
	is_hurt = false  # Reset hurt state
	is_invincible = false  # Reset invincibility
	velocity = Vector2.ZERO  # Reset velocity

	# Set position to the starting point (you can modify this)
	position = Vector2(200, 100)

	# Reset animations and transparency
	anim.play("idle")  # Set the animation to idle or start
	modulate = Color(1, 1, 1, 1)  # Reset transparency

	# Optional: You can reset other properties (like score or power-ups) if needed
	print("Player reset complete!")
