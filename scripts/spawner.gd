extends Node2D

@onready var PLAYER = get_node("../Player")
@onready var CAMERA = get_node("../Player/Camera2D")
@export var Enemy : PackedScene

const TOP_LIMIT = 0
const BOTTOM_LIMIT = 300
const LEFT_LIMIT = 600
const RIGHT_LIMIT = 600

const TOP_SPAWN = 500

const TIMER_START = .8
var timer = TIMER_START

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer -= delta
	if timer <= 0:
		spawn()
		timer = TIMER_START

func spawn():
	var xPos = CAMERA.get_screen_center_position().x + LEFT_LIMIT - randi() % (LEFT_LIMIT + RIGHT_LIMIT)
	var yPos = CAMERA.get_screen_center_position().y + TOP_LIMIT - randi() % (TOP_LIMIT + BOTTOM_LIMIT)
	
	var newEnemy = Enemy.instantiate()
	add_child(newEnemy)
	newEnemy.setup(PLAYER, CAMERA)
	var rando = randi() % 3
	if rando == 0:
		newEnemy.global_position = Vector2(CAMERA.get_screen_center_position().x - LEFT_LIMIT, yPos)
		newEnemy.velocity.x = 100
	elif rando == 1:
		newEnemy.global_position = Vector2(CAMERA.get_screen_center_position().x + RIGHT_LIMIT, yPos)
		newEnemy.velocity.x = -100
	else:
		newEnemy.global_position = Vector2(xPos, CAMERA.get_screen_center_position().y - TOP_SPAWN)
