extends Node2D

# Caches a reference to the UI node, allowing easy access to the UI in the scene.
@onready var UI := get_node("../UI")
# Caches a reference to the Player node, providing easy access to player-related operations.
@onready var PLAYER := get_node("../Player")
# Caches a reference to the Camera2D node attached to the player, used for positioning and zoom calculations.
@onready var CAMERA := get_node("../Player/Camera2D")

# Defines an export variable for different enemy scenes, allowing them to be set in the editor.
@export var Enemy : PackedScene
@export var Shrimp : PackedScene
@export var Clam : PackedScene
@export var Swarmer : PackedScene
@export var Boss : PackedScene

# Defines an export variable for item platform scene, allowing it to be set in the editor.
@export var ItemPlatform: PackedScene

# Constants for vertical and horizontal spawn modifiers.
const VERT_BASE := 350
const VERT_MOD := 400
const HORIZ_MOD := 600

# Constant for the top spawn position.
const TOP_SPAWN := 500
var topSpawnMod = TOP_SPAWN

# Spawn rate of waves. Each entry contains height minimum and spawn time between waves.
const TIMER_LIST := [
	[0, 1.3],
	[500, 1.3],
	[2000, 1.3],
	[5000, 1.3],
	[8000, 1.3],
	[11000, 1.3]
]
var timerIndex := 0
var timer := TIMER_LIST[0][1]

# Stores the current height of the player, used to determine enemy spawn rates and difficulty.
var height : int

# Platform spawn frequency and counter.
var platformFrequency := 10
var platSpawnCounter := 0

# Get all wave assets in "enemy waves" folder to be used later.
var enemyWavesArray = Global.getFilePathsByExtension("res://Enemy Waves/", "tscn")
var enemyWavesRandomYSpawnMax = -768/2  # Max height enemies will randomly set their spawn position to.
var enemyWavesRandomXSpawnMax = 1024/2  # Max distance enemies will randomly set their spawn position to from center.
var enemyOdds : Array  # Should be the same number of entries of waves. Dictates how likely a specific wave can be chosen.

# Data for each wave, including delay and randomization properties.
var enemyWavesData = {
	0: {
		"wave_delay_next": 3.5,                  # Delay applied when this wave spawns for the next wave
		"randomize_horizontally": true,       # Randomize positions of all elements horizontally
		"randomize_vertically": false,         # Randomize positions of all elements vertically
		"item_platform_increment_weight": 1,   # How much to increment the item platform frequency
	},
	1: {
		"wave_delay_next": 4.2,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	2: {
		"wave_delay_next": 4.8,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	3: {
		"wave_delay_next": 5.4,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	4: {  # New wave data
		"wave_delay_next": 6,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	5: {  # New wave data
		"wave_delay_next": 6.4,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	# Add more entries as needed
	6: {
		"wave_delay_next": 4.5,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	
	7: {
		"wave_delay_next": 3,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	8: {
		"wave_delay_next": 3.3,
		"randomize_horizontally": true,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	9: {
		"wave_delay_next": 3.3,
		"randomize_horizontally": true,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
	10: {
		"wave_delay_next": 3.3,
		"randomize_horizontally": false,
		"randomize_vertically": false,
		"item_platform_increment_weight": 1,
	},
}

const OFFSCREEN_LOOP = 2
var offscreenSpawns = 0

# Called when the node enters the scene; initializes values like top spawn modifier.
func _ready():
	topSpawnMod = TOP_SPAWN / CAMERA.zoom.y

# Spawns a boss enemy at the camera's center position.
func spawn_boss():
	spawn(CAMERA.get_screen_center_position(), true, true)

# Called every frame; handles timer updates and checks if it's time to spawn new enemies.
func _process(delta):
	height = UI.get_height()
	check_height_table()
	timer -= delta
	if timer <= 0:
		set_spawns()

# Determines the current spawn timer value based on player height and updates the timer index.
func get_timer():
	if timerIndex == TIMER_LIST.size() - 1:
		return TIMER_LIST[-1][1]
	else:
		if height >= TIMER_LIST[timerIndex + 1][0]:
			timerIndex += 1
		return TIMER_LIST[timerIndex][1]

# Adjusts enemy odds and platform frequency based on player height to increase difficulty dynamically.
func check_height_table():
	if height < 1000:
		enemyOdds = [1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		platformFrequency = 3
	elif height < 2500:
		enemyOdds = [825, 50, 50, 50, 25, 25, 25, 25, 125, 125, 125]
		platformFrequency = 3.5
	elif height < 4000:
		enemyOdds = [500, 150, 150, 100, 100, 100, 100, 100, 200, 200, 200]
		platformFrequency = 4
	elif height < 6500:
		enemyOdds = [300, 150, 150, 100, 100, 100, 100, 100, 100, 100, 100]
		platformFrequency = 4.5
	else:
		enemyOdds = [100, 150, 150, 100, 100, 100, 100, 100, 100, 100, 100]
		platformFrequency = 5

	if UI.paused:
		platformFrequency *= 0.75

# Handles the spawning of enemies at specific screen positions, including off-screen.
func set_spawns():
	var screenX : int = ProjectSettings.get_setting("display/window/size/viewport_width") / CAMERA.zoom.x
	var screenY : int = ProjectSettings.get_setting("display/window/size/viewport_height") / CAMERA.zoom.y
	spawn(CAMERA.get_screen_center_position(), true)
	offscreenSpawns += 2
	if offscreenSpawns > OFFSCREEN_LOOP:
		offscreenSpawns = 0
		spawn(Vector2(CAMERA.get_screen_center_position().x, CAMERA.get_screen_center_position().y - screenY))

# Handles the actual instantiation and positioning of enemies, bosses, or item platforms.
func spawn(center, original = false, boss = false):
	var newSpawn = null
	var isItem := false
	var timer_new_delay := 1.0
	var enemy_wave_spawn_index := -1
	var enemy_wave_item_platform_increment_weight = 1
	var specificHoriz : int = HORIZ_MOD if original else HORIZ_MOD / 2

	if boss:
		newSpawn = Boss.instantiate()
	else:
		if platSpawnCounter >= platformFrequency and original:
			newSpawn = ItemPlatform.instantiate()
			if PLAYER.mobile:
				newSpawn.scale.x *= 2
			platSpawnCounter = 0
			isItem = true
		else:
			var totalOdds := 0
			for i in enemyOdds:
				totalOdds += i
			var enemyRando := randi() % totalOdds
			for i in enemyWavesArray.size():
				enemyRando -= enemyOdds[i]
				if enemyRando < 0:
					enemy_wave_spawn_index = i
					newSpawn = load(enemyWavesArray[enemy_wave_spawn_index]).instantiate()
					break

	if newSpawn == null:
		return

	add_child(newSpawn)

	if isItem:
		var yPos : float = center.y - (VERT_BASE / CAMERA.zoom.y) - randi() % VERT_MOD
		var rando = randi() % 2
		if rando == 0:
			newSpawn.global_position = Vector2(center.x - HORIZ_MOD, yPos)
			newSpawn.velocity.x = 100
		elif rando == 1:
			newSpawn.global_position = Vector2(center.x + HORIZ_MOD, yPos)
			newSpawn.velocity.x = -100
		newSpawn.setup(CAMERA, PLAYER)
		timer_new_delay = get_timer()
	elif boss:
		var xPos : float = center.x + specificHoriz - randi() % (specificHoriz * 2)
		newSpawn.global_position = Vector2(xPos, center.y - topSpawnMod)
		newSpawn.setup(CAMERA, PLAYER)
		timer_new_delay = get_timer()
	else:
		newSpawn.global_position = Vector2(center.x, center.y - topSpawnMod)
		for _e in newSpawn.get_child_count():
			var _wave_instance = newSpawn.get_child(0)
			if enemyWavesData[enemy_wave_spawn_index].randomize_horizontally:
				_wave_instance.position.x = randf_range(enemyWavesRandomXSpawnMax, -enemyWavesRandomXSpawnMax)
			if enemyWavesData[enemy_wave_spawn_index].randomize_vertically:
				_wave_instance.position.y = randf_range(enemyWavesRandomYSpawnMax, 0)
			_wave_instance.reparent(self, true)
			_wave_instance.setup(CAMERA, PLAYER)
		timer_new_delay = enemyWavesData[enemy_wave_spawn_index].wave_delay_next * get_timer()
		enemy_wave_item_platform_increment_weight = enemyWavesData[enemy_wave_spawn_index].item_platform_increment_weight
		newSpawn.queue_free()

	timer = timer_new_delay

	if original:
		platSpawnCounter += enemy_wave_item_platform_increment_weight
