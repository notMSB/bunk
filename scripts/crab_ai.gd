extends Node2D

var player
@onready var enemy = get_parent()

var changed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !changed and enemy.global_position.distance_to(player.global_position) < 400:
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity.x = direction.x
		enemy.velocity.y = direction.y
		enemy.velocity *= 200
		changed = true

func setup(p):
	player = p
