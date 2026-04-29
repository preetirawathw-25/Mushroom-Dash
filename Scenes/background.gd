extends Node2D

@onready var player = $Player
@onready var hearts = [$CanvasLayer/heart1, $CanvasLayer/heart2, $CanvasLayer/heart3]
@onready var mushroom_label = $CanvasLayer/MushroomLabel
@onready var timer_label = $CanvasLayer/TimerLabel
var player_finished = false
var game_over_shown = false

func _ready():
	# Initialize UI
	update_hearts()
	player.life_changed.connect(_on_player_life_changed)
	player.mushroom_collected.connect(_on_mushroom_collected)
	player.died.connect(_on_player_died)  # Connect to new player death signal
	
	if GlobalManager.player_rest:
		reset_game()

func reset_game():
	
	player.global_position = Vector2(200, 100)  # Reset player to start position
	
	player.reset_player()  # Reset player state (e.g., health, animations)
	get_tree().paused = false
	# Reset game state (e.g., lives, mushrooms)
	
	GlobalManager.reset_game()  # Call the global reset_game() function

	# Update the UI with new values
	
	update_ui()


func update_ui():
	

	
	mushroom_label.text = "%d" % GlobalManager.mushrooms_collected
	
func _on_player_life_changed(lives: int):
	print("Lives changed: ", lives)
	update_hearts(lives)
	
	# Immediately check for game over when lives change
	if lives <= 0 and !game_over_shown:
		show_game_over()

func update_hearts(lives = player.lives):
	for i in hearts.size():
		hearts[i].visible = (i < lives)

func _on_mushroom_collected(count: int):
	print("Mushroom collected! Count: ", count)  # Debug to ensure it's being triggered
	mushroom_label.text = str(count)

func _on_river_area_body_entered(body: Node2D):
	
	if body == player:  # More reliable than name check
		body.respawn_near_river()

func _on_river_area_body_entered1(body: Node2D):
	if body == player:  # More reliable than name check
		body.respawn_near_river1()

func _on_river_area_body_entered2(body: Node2D):
	if body == player:  # More reliable than name check
		body.respawn_near_river2()
		
func _on_player_died():
	if !game_over_shown:
		await player.play_death_animation()  # Wait for the animation
		show_game_over()

func _on_game_timer_timeout():
	if is_instance_valid(player) and !game_over_shown:
		player.die()  # This will trigger the death signal
		show_game_over()

func _process(delta):
	update_timer_display()

func update_timer_display():
	var time_left = int($GameTimer.time_left)
	timer_label.text = "%02d:%02d" % [time_left / 60, time_left % 60]
	
func calculate_score() -> int:
	var mushrooms = player.mushroom_count
	var lives = player.lives
	var time_left = int($GameTimer.time_left)

	if player_finished:
		# Better score for fast finish with more lives and mushrooms
		return (time_left * 2) + (mushrooms * 10) + (lives * 50)
	else:
		# No bonus for time — just mushrooms and lives
		return (mushrooms * 10) + (lives * 50)

func show_game_over():
	game_over_shown = true
	var score = calculate_score()
	print("Game Over! Score: ", score)

	var game_over = preload("res://Scenes/GameOver.tscn").instantiate()
	get_tree().root.add_child(game_over)

	await get_tree().process_frame

	# Center the GameOver scene on the camera
	var camera = get_viewport().get_camera_2d()
	if camera:
		game_over.global_position = camera.global_position

	game_over.set_score(score)

	# ✅ Only pause the game AFTER everything is shown
	get_tree().paused = true
func _on_finish_line_body_entered(body):
	if body == player:
		player_finished = true
		show_game_over()
