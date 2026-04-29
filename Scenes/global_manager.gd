extends Node

# Global variables for game state
var player_rest = false  # Initially false, becomes true when retry is pressed
var lives = 3
var mushrooms_collected = 0

# This method resets the game (player state, lives, etc.)
func reset_game():
	player_rest = false  # Reset the flag after retrying
	lives = 3  # Reset the lives
	mushrooms_collected = 0  # Reset mushroom count
	# Reset any other game state here, like player position or score if needed
	print("Game reset!")
var bgm_player: AudioStreamPlayer

func _ready():
	if not bgm_player:
		bgm_player = AudioStreamPlayer.new()
		
		# Load the audio stream
		var stream = load("res://assets/sound/bg_music.mp3") as AudioStream
		stream.loop = true  # Set the loop property on the AudioStream
		
		bgm_player.stream = stream
		bgm_player.volume_db = -25
		add_child(bgm_player)
		bgm_player.play()  # Start playback manually
