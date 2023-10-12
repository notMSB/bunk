extends StaticBody2D

@onready var camera = get_node("../Player/Camera2D")

func _process(_delta):
	position.y += .02
	if position.y > camera.get_screen_center_position().y + 500:
		queue_free()
