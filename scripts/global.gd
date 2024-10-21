extends Node

var runScore := 0
var highScore 		:= 0
var easy 		:= false
#var usedWeapon 	:= 3
var shame 		:= false
var useMobile 	= null
var using_keyboard = true

# Player object
var player = null
var UI = null
var BackgroundLayer = null
var Spawner = null
# Weapon system

# Signals
signal elevator_paused
signal elevator_resumed

enum PICKUP {fuel, health, weapon, grenade, EMP, Photon_Barrier, Time_Freeze, Portal_Trinket, length}

var elevation_threshold_data = {
	enemy_spawn_threshold = [1000, 2500, 4000, 6500],	# Thresholds for enemy wave chances
	timer_list = [
		# Spawn rate of waves. 
		# first entry: height minimum for entry
		# Second entry: spawn time between waves. 
			[0, 		1.3]
		,	[500, 		1.3] 
		,	[2000, 		1.2] 
		,	[5000, 		1.1] 
		,	[8000, 		1.0] 
		,	[11000, 	0.9]
	]
}


func game_over():
	
	# Called once the current game/ends and the player has died
	
	# set highScore
	runScore = player.UI.get_height()
	if runScore > Global.highScore: Global.highScore = runScore
	
	# Spawn game over menu
	var _inst = load("res://scenes/Game Over.tscn").instantiate()
	get_tree().root.add_child(_inst)
	#_inst.position = 
	
	pass

func spawn_notif_text(_message, _caller, _y_offset = 48):
	
	# Spawns some floating text which dissappears shortly. 
	# Can be used for a bunch of stuff
	
	var _text = load("res://scenes/pickup_text.tscn").instantiate()
	
	
	# Set to parent of whatever we're on, like a sibling. 
	#get_parent().add_child(_text)
	_caller.add_sibling(_text)
	_text.position = _caller.position - Vector2(0, _y_offset)
	
	# Set acquired text
	_text.set_text(_message)
	
	# Return instance ID
	return _text
	
	pass

func getFilePathsByExtension(directoryPath: String, extension: String, recursive: bool = true) -> Array:
	
	#	https://www.reddit.com/r/godot/comments/k1t53k/getting_tscn_children_from_levels_folder/
	
	# returns one array containing all elements found within a folder. 
	# Entries are just paths to that element.
	# Does not create sub arrays, only the one array with all elements. 
	
	# Usage: 
	#var directoryPath = "res://path/to/Levels"
	#var extension = "tscn"
	#var foundPaths = getFilePathsByExtension(directoryPath, extension)
	
	
	#var dir := Directory.new()
	
	var dir := DirAccess.open(directoryPath)
	#if dir != OK:
	if dir == null:
		printerr("Warning: could not open directory: ", directoryPath)
		return []
		
	#if dir.list_dir_begin(true, true) != OK:
		#printerr("Warning: could not list contents of: ", directoryPath)
		#return []
	dir.list_dir_begin()
	
	
	var filePaths := []
	var fileName := dir.get_next()
	
	while fileName != "":
		if dir.current_is_dir():
			if recursive:
				var dirPath = dir.get_current_dir() + "/" + fileName
				filePaths += getFilePathsByExtension(dirPath, extension, recursive)
		else:
			if fileName.get_extension() == extension:
				var filePath = dir.get_current_dir() + "/" + fileName
				filePaths.append(filePath)
		
		fileName = dir.get_next()
	
	# Not necessary, calling get_next() and getting an empty string automatically ends it. 
	#dir.list_dir_emd()
	
	return filePaths


func _input(event: InputEvent) -> void:
	# Switch to controller input
	if event.is_pressed() && using_keyboard && (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		using_keyboard = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
		if is_instance_valid(player):	player.get_node("Target Reticle").show()
		
	# Switch to keyboard input
	elif event.is_pressed() && !using_keyboard && (event is InputEventKey or event is InputEventMouse or event is InputEventMouseMotion):
		using_keyboard = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		if is_instance_valid(player):	player.get_node("Target Reticle").hide()

