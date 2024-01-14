extends "res://scripts/enemy.gd"

var player

const THRESHOLD := 100
var nextCheck : int

func _ready():
	nextCheck = health - THRESHOLD
	$UI/HPText.text = str(health)

func _physics_process(_delta):
	recalibrate()
	if health <= nextCheck: 
		position.y -= 300
		nextCheck -= THRESHOLD
	else: position.y += 0.5

func setup(_cam, p):
	player = p
	recalibrate()

func recalibrate():
	global_position.x = player.global_position.x - $EnemyShape.shape.size.x*.5 + player.get_node("CollisionShape2D").shape.size.x
