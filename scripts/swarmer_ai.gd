extends Node2D

var player : CharacterBody2D
@onready var enemy = get_parent()

var time_speed = 1.0

func setup(p, offset = 0):
	player = p
	var direction : Vector2 = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = direction * 300
	if offset == 0:
		var newEnemy = enemy.duplicate()
		get_node("../../").add_child(newEnemy)
		newEnemy.get_node("AI").setup(p, 1)
		newEnemy = enemy.duplicate()
		get_node("../../").add_child(newEnemy)
		newEnemy.get_node("AI").setup(p, -1)
	else:
		var reposition := direction.rotated(deg_to_rad(90))
		enemy.position += 100 * reposition * offset

func on_enemy_damaged():
	
	pass
