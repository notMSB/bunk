extends Node2D

@export var Explosion : PackedScene

func use():
	var boom = Explosion.instantiate()
	add_child(boom)
	boom.scale = Vector2(2.5,2.5)
	boom.position = position
	boom.setup(10, null)
