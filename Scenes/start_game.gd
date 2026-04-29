extends Control

@onready var play_button = $play
@onready var exit_btn = $exit
@onready var leader_btn = $leaderboard
@onready var leaderboard_screen = preload("res://Scenes/LeaderboardScreen.tscn")
func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	exit_btn.pressed.connect(_on_exit_button_pressed)
	leader_btn.pressed.connect(_on_leaderboard_button_pressed)
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/background.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_leaderboard_button_pressed():
	
	var leaderboard_instance = leaderboard_screen.instantiate()
	
	get_tree().root.add_child(leaderboard_instance)
