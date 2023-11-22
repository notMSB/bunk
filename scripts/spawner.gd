extends Node2D

@onready var UI := get_node("../UI")
@onready var PLAYER := get_node("../Player")
@onready var CAMERA := get_node("../Player/Camera2D")
@export var Enemy : PackedScene
@export var Shrimp : PackedScene
@export var Clam : PackedScene

const TOP_LIMIT := 600
const BOTTOM_LIMIT := 200
const LEFT_LIMIT := 600
const RIGHT_LIMIT := 600

const TOP_SPAWN := 500

const EARLY_TIMER := 1.0
const TIMER_START := .8
var timer := EARLY_TIMER

var height : int

enum e {clam, shrimp, crab}
var enemyOdds : Array

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	height = UI.get_height()
	check_height_table()
	timer -= delta
	if timer <= 0:
		spawn()
		timer = TIMER_START if height >= 500 else EARLY_TIMER

func check_height_table():
	if height < 1000: enemyOdds = [0, 0, 100]
	elif height < 2500: enemyOdds = [3, 8, 89]
	elif height < 4000: enemyOdds = [5, 10, 85]
	elif height < 6500: enemyOdds = [7, 18, 75]
	else: enemyOdds = [10, 25, 65]

func spawn():
	var xPos : float = CAMERA.get_screen_center_position().x + LEFT_LIMIT - randi() % (LEFT_LIMIT + RIGHT_LIMIT)
	var yPos : float = CAMERA.get_screen_center_position().y - TOP_LIMIT + randi() % (TOP_LIMIT - BOTTOM_LIMIT)
	
	var totalOdds := 0
	for i in enemyOdds: totalOdds += i
	
	var enemyRando := randi() % totalOdds
	var newEnemy : CharacterBody2D
	
	enemyRando -= enemyOdds[e.clam]
	if enemyRando < 0: #todo: get this in a loop
		newEnemy = Clam.instantiate()
	else:
		enemyRando -= enemyOdds[e.shrimp]
		if enemyRando < 0:
			newEnemy = Shrimp.instantiate()
		else:
			newEnemy = Enemy.instantiate()
	add_child(newEnemy)
	newEnemy.setup(PLAYER, CAMERA)
	var rando = randi() % 10
	if rando == 0:
		newEnemy.global_position = Vector2(CAMERA.get_screen_center_position().x - LEFT_LIMIT, yPos)
		newEnemy.velocity.x = 100
	elif rando == 1:
		newEnemy.global_position = Vector2(CAMERA.get_screen_center_position().x + RIGHT_LIMIT, yPos)
		newEnemy.velocity.x = -100
	else:
		newEnemy.global_position = Vector2(xPos, CAMERA.get_screen_center_position().y - TOP_SPAWN)
