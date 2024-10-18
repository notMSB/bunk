extends Node2D

@onready var enemy := get_parent()
@onready var bulletHolder := get_node("../Projectiles")
@export var Bullet : PackedScene

var player : CharacterBody2D
const COOLDOWN := 1.4
var shotCooldown := COOLDOWN
var flipped := false
var xScale := 1
var yScale := 1

func _process(delta):
	flip(enemy.global_position.x > player.global_position.x)
	shotCooldown -= delta
	if shotCooldown <= 0 and !enemy.killTimerSet and enemy.global_position.distance_to(player.global_position) < 550:
		var shot = Bullet.instantiate()
		shot.get_node("Sprite2D").modulate = Color.RED
		bulletHolder.add_child(shot)
		
		shot.fire(player.global_position, enemy.global_position, 1, 0, 65, .4,)
		shotCooldown = COOLDOWN

func flip(playerLeft):
	if playerLeft and !flipped:
		enemy.scale = Vector2(-1 * xScale, yScale)
		flipped = true
		enemy.get_node("UI").scale = Vector2(-1 * xScale, yScale)
	elif !playerLeft and flipped:
		enemy.scale = Vector2(- 1 * xScale, -1 * yScale)
		flipped = false
		enemy.get_node("UI").scale = Vector2(xScale, yScale)
	#else:
	#	enemy.scale = Vector2(1, 1)

func setup(p):
	xScale = enemy.scale.x
	yScale = enemy.scale.y
	player = p

func on_enemy_damaged():
	
	pass
