extends Node2D

@onready var enemy = get_parent()
@onready var bulletHolder = get_node("../Projectiles")
@export var Bullet : PackedScene

var player
const COOLDOWN = 1
var shotCooldown = COOLDOWN
var flipped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	flip(enemy.global_position.x > player.global_position.x)
	shotCooldown -= delta
	if shotCooldown <= 0 and !enemy.killTimerSet and enemy.global_position.distance_to(player.global_position) < 600:
		var shot = Bullet.instantiate()
		shot.get_node("Sprite2D").modulate = Color.RED
		bulletHolder.add_child(shot)
		
		shot.fire(player.global_position, enemy.global_position, 1, 1, .25)
		shotCooldown = COOLDOWN

func flip(playerLeft):
	if playerLeft and !flipped:
		enemy.scale = Vector2(-1, 1)
		flipped = true
		enemy.get_node("UI").scale = Vector2(-1, 1)
	elif !playerLeft and flipped:
		enemy.scale = Vector2(-1, -1)
		flipped = false
		enemy.get_node("UI").scale = Vector2(1, 1)
	#else:
	#	enemy.scale = Vector2(1, 1)

func setup(p):
	player = p
