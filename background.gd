extends ParallaxBackground

var speed = 50  # Speed of the scrolling (pixels per second)

func _process(delta):
	offset.x -= speed * delta
