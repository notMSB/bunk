extends "res://scripts/enemy.gd"

@onready var bar := get_node("../../UI/BossBar")
@onready var barText := get_node("../../UI/BossBar/Text")
var player : CharacterBody2D
#var playerY : float

const THRESHOLD := 50
var nextCheck : int

var spawnOffset : float = 400

const BASE_SPEED := .3
const SPEED_RAMP := .001
const MAX_SPEED := 1.6
var speed := BASE_SPEED

func _ready():
	nextCheck = health - THRESHOLD
	bar.max_value = health
	bar.value = health
	barText.text = str(health)
	bar.visible = true

func _physics_process(_delta):
	recalibrate()
	if isPlatform: position.y += BASE_SPEED
	else:
		var basePos = camera.get_screen_center_position().y + spawnOffset
		if position.y > basePos: position.y = basePos
		if health <= nextCheck: 
			position.y = basePos
			nextCheck -= THRESHOLD
			speed = BASE_SPEED
		else: 
			position.y -= speed
			if speed < MAX_SPEED: speed += SPEED_RAMP

func setup(cam, p):
	camera = cam
	player = p
	
	position.y = camera.get_screen_center_position().y + spawnOffset
	
	recalibrate()

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
	global_position.x = player.global_position.x - $EnemyShape.shape.size.x*.42 + player.get_node("CollisionShape2D").shape.size.x
	#playerY = player.global_position.y

func _on_contact_damage_body_entered(body):
	if $ContactDamage.visible and body.collision_layer == 65: #damage player
		var left := false if body.position.x > position.x else true
		body.take_damage(left, 1, true)
