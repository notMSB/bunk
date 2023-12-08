extends Node2D

@onready var UI := get_node("../UI")
@onready var PLAYER := get_node("../Player")
@onready var CAMERA := get_node("../Player/Camera2D")
@export var Enemy : PackedScene
@export var Shrimp : PackedScene
@export var Clam : PackedScene
@export var Swarmer : PackedScene

@export var ItemPlatform: PackedScene

const VERT_BASE := 350
const VERT_MOD := 400
const HORIZ_MOD := 600

const TOP_SPAWN := 500

const EARLY_TIMER := 1.1
const TIMER_START := 1.0
var timer := EARLY_TIMER

var height : int

var platformFrequency := 10
var platSpawnCounter := 0

var enemyScenes : Array
var enemyOdds : Array

const OFFSCREEN_LOOP = 2
var offscreenSpawns = 0

func _ready():
	enemyScenes = [Swarmer, Clam, Shrimp, Enemy]

func _process(delta):
	height = UI.get_height()
	check_height_table()
	timer -= delta
	if timer <= 0:
		set_spawns()
		timer = TIMER_START if height >= 500 else EARLY_TIMER

func check_height_table():
	if height < 1000: 
		enemyOdds = [2, 0, 0, 98]
		platformFrequency = 8
	elif height < 2500: 
		enemyOdds = [4, 3, 8, 85]
		platformFrequency = 10
	elif height < 4000: 
		enemyOdds = [6, 5, 10, 79]
		platformFrequency = 12
	elif height < 6500: 
		enemyOdds = [8, 7, 18, 67]
		platformFrequency = 14
	else:
		enemyOdds = [10, 10, 25, 55]
		platformFrequency = 16

func set_spawns():
	var screenX : int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screenY : int = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	spawn(CAMERA.get_screen_center_position(), true)
	spawn(Vector2(CAMERA.get_screen_center_position().x - screenX, CAMERA.get_screen_center_position().y))
	spawn(Vector2(CAMERA.get_screen_center_position().x + screenX, CAMERA.get_screen_center_position().y))
	offscreenSpawns +=1
	if offscreenSpawns > OFFSCREEN_LOOP: 
		offscreenSpawns = 0
		spawn(Vector2(CAMERA.get_screen_center_position().x, CAMERA.get_screen_center_position().y - screenY))

func spawn(center, original = false):
	var newSpawn : CharacterBody2D
	var isItem := false
	
	var specificHoriz : int = HORIZ_MOD if original else HORIZ_MOD / 2
	
	if original: platSpawnCounter +=1
	if platSpawnCounter >= platformFrequency and original: 
		newSpawn = ItemPlatform.instantiate()
		platSpawnCounter = 0
		isItem = true
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
	if isItem:
		var yPos : float = center.y - VERT_BASE - randi() % (VERT_MOD)
		var rando = randi() % 2
		if rando == 0:
			newSpawn.global_position = Vector2(center.x - HORIZ_MOD, yPos)
			newSpawn.velocity.x = 100
		elif rando == 1:
			newSpawn.global_position = Vector2(center.x + HORIZ_MOD, yPos)
			newSpawn.velocity.x = -100
	else:
		var xPos : float = center.x + specificHoriz - randi() % (specificHoriz * 2)
		newSpawn.global_position = Vector2(xPos, center.y - TOP_SPAWN)
	newSpawn.setup(CAMERA, PLAYER)
