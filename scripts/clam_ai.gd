extends Node2D

@onready var enemy := get_parent()
@onready var bulletHolder := get_node("../Projectiles")
@export var Bullet : PackedScene

var player : CharacterBody2D
const COOLDOWN := 2.0
var shotCooldown := COOLDOWN
var flipped := false

func _process(delta):
	shotCooldown -= delta
	if shotCooldown <= 0 and !enemy.killTimerSet and enemy.global_position.distance_to(player.global_position) < 600:
		var bulletOrigin = enemy.position + Vector2(16, 32) #set all bullets to spawn from the middle
		for i in 8:
			var shot := Bullet.instantiate()
			shot.get_node("Sprite2D").modulate = Color.RED
			bulletHolder.add_child(shot)
			var shotDir : Vector2
			match i: #shoot a spread of 8 from the middle
				0: shotDir = Vector2(bulletOrigin.x, bulletOrigin.y + 5)
				1: shotDir = Vector2(bulletOrigin.x, bulletOrigin.y - 5)
				2: shotDir = Vector2(bulletOrigin.x + 5, bulletOrigin.y)
				3: shotDir = Vector2(bulletOrigin.x + 5, bulletOrigin.y + 5)
				4: shotDir = Vector2(bulletOrigin.x + 5, bulletOrigin.y - 5)
				5: shotDir = Vector2(bulletOrigin.x - 5, bulletOrigin.y)
				6: shotDir = Vector2(bulletOrigin.x - 5, bulletOrigin.y + 5)
				7: shotDir = Vector2(bulletOrigin.x - 5, bulletOrigin.y - 5)
			shot.fire(shotDir, bulletOrigin, 1, 0, 1, .25)
		shotCooldown = COOLDOWN

func setup(p):
	player = p
