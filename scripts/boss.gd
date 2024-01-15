extends "res://scripts/enemy.gd"

@onready var bar = get_node("../../UI/BossBar")
@onready var barText = get_node("../../UI/BossBar/Text")
var player

const THRESHOLD := 100
var nextCheck : int

func _ready():
	nextCheck = health - THRESHOLD
	bar.max_value = health
	bar.value = health
	barText.text = str(health)
	bar.visible = true

func _physics_process(_delta):
	recalibrate()
	if health <= nextCheck: 
		position.y -= 300
		nextCheck -= THRESHOLD
	else: position.y += 0.5

func setup(_cam, p):
	player = p
	recalibrate()
	position.y -= 300

func take_damage(amount):
	health -= amount
	if health <= 0: 
		change()
		bar.visible = false
		get_node("../../UI").unpause(player.position.y)
	bar.value = health
	barText.text = str(health)

func recalibrate():
	global_position.x = player.global_position.x - $EnemyShape.shape.size.x*.5 + player.get_node("CollisionShape2D").shape.size.x
