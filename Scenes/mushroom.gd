extends Area2D

@export var mushroom_value: int = 1

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Something entered:", body.name)
	if body.is_in_group("Player") and body.has_method("collect_mushroom"):
		body.collect_mushroom(mushroom_value)
		queue_free()
