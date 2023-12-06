extends Node2D

@onready var UI := get_node("../UI")
@onready var PLAYER := get_node("../Player")
@onready var CAMERA := get_node("../Player/Camera2D")
@export var Enemy : PackedScene
@export var Shrimp : PackedScene
@export var Clam : PackedScene
@export var Swarmer : PackedScene

@export var ItemPlatform: PackedScene

const TOP_LIMIT := 600
const BOTTOM_LIMIT := 200
const LEFT_LIMIT := 600
const RIGHT_LIMIT := 600

const TOP_SPAWN := 500

const EARLY_TIMER := 1.0
const TIMER_START := .75
var timer := EARLY_TIMER

var height : int

var platformFrequency := 10
var platSpawnCounter := 0

var enemyScenes : Array
var enemyOdds : Array

func _ready():
	enemyScenes = [Swarmer, Clam, Shrimp, Enemy]

func _process(delta):
	height = UI.get_height()
	check_height_table()
	timer -= delta
	if timer <= 0:
		spawn()
		timer = TIMER_START if height >= 500 else EARLY_TIMER

func check_height_table():
	if height < 1000: 
		enemyOdds = [4, 0, 0, 96]
		platformFrequency = 10
	elif height < 2500: 
		enemyOdds = [6, 3, 8, 83]
		platformFrequency = 15
	elif height < 4000: 
		enemyOdds = [8, 5, 10, 78]
		platformFrequency = 20
	elif height < 6500: 
		enemyOdds = [10, 7, 18, 65]
		platformFrequency = 25
	else: 
		enemyOdds = [12, 10, 25, 53]
		platformFrequency = 30

func spawn():
	platSpawnCounter +=1
	var xPos : float = CAMERA.get_screen_center_position().x + LEFT_LIMIT - randi() % (LEFT_LIMIT + RIGHT_LIMIT)
	var yPos : float = CAMERA.get_screen_center_position().y - TOP_LIMIT + randi() % (TOP_LIMIT - BOTTOM_LIMIT)
	
	var newSpawn : CharacterBody2D
	
	if platSpawnCounter >= platformFrequency: 
		newSpawn = ItemPlatform.instantiate()
		platSpawnCounter = 0
	else:
		var totalOdds := 0
		for i in enemyOdds: totalOdds += i
		
		var enemyRando := randi() % totalOdds
		
		for i in enemyScenes.size():
			enemyRando -= enemyOdds[i]
			if enemyRando < 0:
				newSpawn = enemyScenes[i].instantiate()
				break
	add_child(newSpawn)
	var rando = randi() % 10
	if rando == 0:
		newSpawn.global_position = Vector2(CAMERA.get_screen_center_position().x - LEFT_LIMIT, yPos)
		newSpawn.velocity.x = 100
	elif rando == 1:
		newSpawn.global_position = Vector2(CAMERA.get_screen_center_position().x + RIGHT_LIMIT, yPos)
		newSpawn.velocity.x = -100
	else:
		newSpawn.global_position = Vector2(xPos, CAMERA.get_screen_center_position().y - TOP_SPAWN)
	newSpawn.setup(CAMERA, PLAYER)
