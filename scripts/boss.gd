extends "res://scripts/enemy.gd"

@onready var bar := get_node("../../UI/BossBar")
@onready var barText := get_node("../../UI/BossBar/Text")
var player : CharacterBody2D

#var playerY : float

const THRESHOLD := 100
var nextCheck : int

const BASE_SPEED := .3
const SPEED_RAMP := .001
var speed := BASE_SPEED

func _ready():
	nextCheck = health - THRESHOLD
	bar.max_value = health
	bar.value = health
	barText.text = str(health)
	bar.visible = true

func _physics_process(_delta):
	recalibrate()
	if health <= nextCheck: 
		position.y += 100
		nextCheck -= THRESHOLD
		speed = BASE_SPEED
	else: 
		position.y -= speed
		speed += SPEED_RAMP

func setup(_cam, p):
	player = p
	recalibrate()
	position.y += 700

func take_damage(amount):
	health -= amount
	if health <= 0: 
		change()
		bar.visible = false
		get_node("../../UI").unpause(player.position.y)
	bar.value = health
	barText.text = str(health)

func recalibrate():
	#if playerY: global_position.y += player.global_position.y - playerY
	global_position.x = player.global_position.x - $EnemyShape.shape.size.x*.5 + player.get_node("CollisionShape2D").shape.size.x
	#playerY = player.global_position.y
