extends Node2D

@onready var UI := get_node("../UI")
@onready var PLAYER := get_node("../Player")
@onready var CAMERA := get_node("../Player/Camera2D")
@export var Enemy : PackedScene
@export var Shrimp : PackedScene
@export var Clam : PackedScene
@export var Swarmer : PackedScene
@export var Boss : PackedScene

@export var ItemPlatform: PackedScene

const VERT_BASE := 350
const VERT_MOD := 400
const HORIZ_MOD := 600

const TOP_SPAWN := 500
var topSpawnMod = TOP_SPAWN

# Spawn rate of waves. 
# first entry: height minimum for entry
# Second entry: spawn time between waves. 
const TIMER_LIST := [
		[0, 		1.3]
	,	[500, 		1.3] 
	,	[2000, 		1.2] 
	,	[5000, 		1.1] 
	,	[8000, 		1.0] 
	,	[11000, 	0.9]
]
var timerIndex := 0
var timer := TIMER_LIST[0][1]

var height : int

var platformFrequency := 10
var platSpawnCounter := 0


#var enemyScenes : Array

# Get all wave assets in "enemy waves" folder to be used later
var enemyWavesArray = Global.getFilePathsByExtension("res://Enemy Waves/", "tscn")
var enemyWavesRandomYSpawnMax = -768/2	# Max height enemies will randomly set their spawn position to
var enemyWavesRandomXSpawnMax = 1024/2	# Max distance enemies will randomly set their spawn position to from centre
var enemyOdds : Array	# Should be the same number of entries of waves. Dictates how likely a specific wave can be chosen

# Data for each wave
# Can b
var enemyWavesData = {
	0 : {
			wave_delay_next			= 1.0	# Delay applied when this wave spawns for the next wave. This allows customization of spawn times
		,	randomize_horizontally 	= false	# Randomize positions of all elements horizontally
		,	randomize_vertically 	= false	# Randomize positions of all elements vertically
	}
	, 1 : {
			wave_delay_next 		= 2.0
		,	randomize_horizontally 	= false
		,	randomize_vertically 	= true
	}
	, 2 : {
			wave_delay_next 		= 3.0
		,	randomize_horizontally 	= true
		,	randomize_vertically 	= false
	}
	, 3 : {
			wave_delay_next 		= 4.0
		,	randomize_horizontally 	= true
		,	randomize_vertically 	= true
	}
}

const OFFSCREEN_LOOP = 2
var offscreenSpawns = 0

func _ready():
	#enemyScenes = [Swarmer, Clam, Shrimp, Enemy]
	topSpawnMod = TOP_SPAWN / CAMERA.zoom.y
	

func spawn_boss():
	spawn(CAMERA.get_screen_center_position(), true, true)

func _process(delta):
	height = UI.get_height()
	
	# Update spawning parameters
	check_height_table()
	
	# Spawn enemies every so often using a timer
	timer -= delta
	if timer <= 0:
		set_spawns()
		

func get_timer():
	if timerIndex == TIMER_LIST.size()-1: return TIMER_LIST[-1][1]
	else:
		if height >= TIMER_LIST[timerIndex+1][0]:
			timerIndex += 1
		#print(TIMER_LIST[timerIndex][1])
		return TIMER_LIST[timerIndex][1]

func check_height_table(): #todo: optimize, should not calculate every frame
	if height < 1000: 
		enemyOdds = [250, 0, 0, 9750]
		platformFrequency = 8
	elif height < 2500: 
		enemyOdds = [350, 300, 800, 8500]
		platformFrequency = 10
	elif height < 4000: 
		enemyOdds = [450, 500, 1000, 7900]
		platformFrequency = 12
	elif height < 6500: 
		enemyOdds = [600, 700, 1800, 6700]
		platformFrequency = 14
	else: 
		enemyOdds = [700, 900, 3000, 5600]
		platformFrequency = 16
	@warning_ignore("narrowing_conversion")
	if UI.paused: platformFrequency *= .33

func set_spawns():
	
	# Get screen position
	var screenX : int = ProjectSettings.get_setting("display/window/size/viewport_width") / CAMERA.zoom.x
	var screenY : int = ProjectSettings.get_setting("display/window/size/viewport_height") / CAMERA.zoom.y
	
	
	# Spawn enemies in the middle. Also randomly spawn a pickup
	spawn(CAMERA.get_screen_center_position(), true)
	
	# Spawn enemies to the left and right
	#spawn(Vector2(CAMERA.get_screen_center_position().x - screenX, CAMERA.get_screen_center_position().y))
	#spawn(Vector2(CAMERA.get_screen_center_position().x + screenX, CAMERA.get_screen_center_position().y))
	
	# Spawn enemies off screen
	offscreenSpawns +=1
	if offscreenSpawns > OFFSCREEN_LOOP: 
		offscreenSpawns = 0
		spawn(Vector2(CAMERA.get_screen_center_position().x, CAMERA.get_screen_center_position().y - screenY))

func spawn(center, original = false, boss = false):
	#var newSpawn : CharacterBody2D
	var newSpawn = null
	var isItem := false
	var timer_new_delay := 1.0
	var enemy_wave_spawn_index := -1
	
	var specificHoriz : int = HORIZ_MOD if original else HORIZ_MOD / 2
	
	# spawn Boss
	if boss: newSpawn = Boss.instantiate();
	else:
		if original: platSpawnCounter +=1
		
		# spawn item platform
		if platSpawnCounter >= platformFrequency and original: 
			newSpawn = ItemPlatform.instantiate()
			if PLAYER.mobile: newSpawn.scale.x *= 2
			platSpawnCounter = 0
			isItem = true
		# Spawn enemy
		else:
			# Figure out what enemy to spawn based on spawning chances of each enemy
			#var totalOdds := 0
			#for i in enemyOdds: totalOdds += i
			#var enemyRando := randi() % totalOdds
			#for i in enemyScenes.size():
				#enemyRando -= enemyOdds[i]
				#
				## Actually spawn enemy
				#if enemyRando < 0:
					#newSpawn = enemyScenes[i].instantiate()
					#break
			
			var totalOdds := 0
			for i in enemyOdds: 
				totalOdds += i
			
			var enemyRando := randi() % totalOdds
			
			for i in enemyWavesArray.size():
				enemyRando -= enemyOdds[i]
				
				# Actually spawn enemy
				if enemyRando < 0:
					enemy_wave_spawn_index = i
					newSpawn = load(enemyWavesArray[enemy_wave_spawn_index]).instantiate()
					break
	
	if newSpawn == null: return
	
	add_child(newSpawn)
	
	# Set up item spawn post-creation
	if isItem:
		var yPos : float = center.y - (VERT_BASE / CAMERA.zoom.y) - randi() % (VERT_MOD)
		var rando = randi() % 2
		if rando == 0:
			newSpawn.global_position = Vector2(center.x - HORIZ_MOD, yPos)
			newSpawn.velocity.x = 100
		elif rando == 1:
			newSpawn.global_position = Vector2(center.x + HORIZ_MOD, yPos)
			newSpawn.velocity.x = -100
		
		newSpawn.setup(CAMERA, PLAYER)
		timer_new_delay = get_timer()
		pass
	elif boss:
		var xPos : float = center.x + specificHoriz - randi() % (specificHoriz * 2)
		newSpawn.global_position = Vector2(xPos, center.y - topSpawnMod)
		newSpawn.setup(CAMERA, PLAYER)
		timer_new_delay = get_timer()
		pass
	# Set up enemy position
	else:
		# Old single-enemy spawning logic
		#var xPos : float = center.x + specificHoriz - randi() % (specificHoriz * 2)
		#newSpawn.global_position = Vector2(xPos, center.y - topSpawnMod)
		
		# Spawn wave at top centre of screen
		newSpawn.global_position = Vector2(center.x, center.y - topSpawnMod)
		
		# Set up each instance in the wave
		for _e in newSpawn.get_child_count():
			# Get first instance, as we reparent each one
			var _wave_instance = newSpawn.get_child(0)
			
			# Randomize positions of instances in the wave if able
			if(enemyWavesData[enemy_wave_spawn_index].randomize_horizontally):
				_wave_instance.position.x = randf_range(enemyWavesRandomXSpawnMax, -enemyWavesRandomXSpawnMax)
				pass
			
			if(enemyWavesData[enemy_wave_spawn_index].randomize_vertically):
				_wave_instance.position.y = randf_range(enemyWavesRandomYSpawnMax, 0)
				pass
			
			# Put instance to spawner instance
			#var _old_position = _wave_instance.global_position
			_wave_instance.reparent(self, true)
			#_wave_instance.global_position = _old_position
			
			# Set up instance after repositioning/moving to spawner
			_wave_instance.setup(CAMERA, PLAYER)
			
			pass
		
		# Delay next wave by this wave's time
		# Multiplies the delay by default timer delay, so it scales with height
		timer_new_delay = enemyWavesData[enemy_wave_spawn_index].wave_delay_next * get_timer()
		
		# Clean up leftover "wave" instance as it's no longer needed
		newSpawn.queue_free()
		pass
	
	#if PLAYER.mobile: newSpawn.scale *= 2
	#timer = get_timer()
	timer = timer_new_delay
