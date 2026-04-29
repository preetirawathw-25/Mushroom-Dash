extends Control

@onready var score_label = $ScoreLabel
@onready var retry_button = $RetryButton
@onready var quit_button = $QuitButton
@onready var name_input = $NameInput
@onready var save_score_button = $SaveScoreButton

var final_score = 0
var api_url = "http://127.0.0.1:5000/submit"  # ADD API HERE

# Godot HTTPRequest object to make the POST request
var http_request = HTTPRequest.new()

func _ready():
	# Connect buttons to their respective functions
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	save_score_button.pressed.connect(_on_save_score_pressed)

	# Add the HTTPRequest to the scene so it can make the request
	add_child(http_request)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	score_label.text = "Your Score: %d" % final_score

func set_score(score: int):
	final_score = score
	score_label.text = "Your Score: %d" % final_score

func _on_retry_pressed():
	GlobalManager.player_rest = true
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/background.tscn")

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_save_score_pressed():
	var name = name_input.text.strip_edges()
	if name == "":
		return  # Optionally show a warning if name is empty
	save_score(name, final_score)
	save_score_button.disabled = true  # Disable the save button after saving

func save_score(name: String, score: int):
	# Prepare data to send to the API
	var data = {
		"name": name,
		"score": score
	}

	# Convert data to JSON format
	var json_data = JSON.stringify(data)

	# Prepare headers
	var headers = ["Content-Type: application/json"]
	
	# Connect the signal to handle response
	http_request.request_completed.connect(_on_request_completed)
	
	# Send the POST request
	var error = http_request.request(api_url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("Failed to send request")

func _on_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	print("Response: ", response)
	print("Status code: ", response_code)
