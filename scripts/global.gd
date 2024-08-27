extends Node

var score 		:= 0
var easy 		:= false
#var usedWeapon 	:= 3
var shame 		:= false
var useMobile 	= null

# Player object
var player = null
# Weapon system



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
