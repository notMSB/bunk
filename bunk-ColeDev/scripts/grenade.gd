extends Node2D

@export var Explosion : PackedScene

func use():
	var boom = Explosion.instantiate()
	call_deferred("add_child", boom)
	boom.scale = Vector2(2.5,2.5)
	boom.position = position
	boom.setup(25, null)
