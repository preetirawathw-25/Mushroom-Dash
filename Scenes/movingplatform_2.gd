extends StaticBody2D


@export var speed = 100  # Speed of movement (pixels per second)
@export var direction = Vector2(0, 1)  # Direction to move (vertical, up/down)
@export var path_length = 400  # Path length for the movement
var start_position: Vector2
var end_position: Vector2
var moving_towards_end = true

func _ready():
	start_position = position
	end_position = start_position + direction.normalized() * path_length

func _physics_process(delta):
	# Move the platform
	if moving_towards_end:
		position += direction.normalized() * speed * delta
		if position.distance_to(end_position) <= 1:
			moving_towards_end = false  # Change direction when the end is reached
	else:
		position -= direction.normalized() * speed * delta
		if position.distance_to(start_position) <= 1:
			moving_towards_end = true  # Change direction when the start is reached
