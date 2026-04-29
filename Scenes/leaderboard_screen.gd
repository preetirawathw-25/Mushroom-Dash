extends Control

@onready var entries_container = $Panel/VBoxContainer/ScrollContainer/LeaderboardList
@onready var http_request = $Panel/HTTPRequest

func _ready():
	# Verify nodes exist
	
	$Panel/VBoxContainer/ScrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	$Panel/VBoxContainer/ScrollContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not entries_container:
		push_error("Entries container not found! Check node path.")
	if not http_request:
		http_request = HTTPRequest.new()
		add_child(http_request)
	
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	http_request.request_completed.connect(_on_request_completed)
	fetch_leaderboard()

func fetch_leaderboard():
	var error = http_request.request("http://127.0.0.1:5000/leaderboard") #ADD API HERE
	if error != OK:
		push_error("Failed to start request: " + str(error))

func _on_request_completed(_result, response_code, _headers, body):
	print("Raw response: ", body.get_string_from_utf8())  # Debug
	
	if response_code == 200:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) == TYPE_ARRAY:
			show_leaderboard(parsed)
		else:
			push_error("Invalid data format")
	else:
		push_error("Request failed: " + str(response_code))

func show_leaderboard(data):
	# Clear existing
	
	for child in entries_container.get_children():
		
		child.queue_free()
	
	entries_container.add_child(HSeparator.new())
	
	data.sort_custom(func(a, b): return b["score"] - a["score"])
	for i in range(data.size()):
		
		var entry = data[i]
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 90)  # Space between columns
		var row_padding = MarginContainer.new()
		row_padding.add_theme_constant_override("margin_top", 4)    # Top padding
		row_padding.add_theme_constant_override("margin_bottom", 4) # Bottom padding
		row_padding.add_child(hbox)
		var rank = Label.new()
		rank.text = "#%d" % (i+1)
		rank.custom_minimum_size.x = 40
		var name = Label.new()
		name.text = entry["name"]
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var score = Label.new()
		score.text = str(entry["score"])
		hbox.add_child(rank)
		hbox.add_child(name)
		hbox.add_child(score)
		entries_container.add_child(row_padding)  # Add padded container instead of raw HBox
		if i < data.size() - 1:
			entries_container.add_child(HSeparator.new())
			
func _on_back_button_pressed():
	queue_free()
