extends CanvasLayer

@onready var Background := get_node("../BackgroundLayer/Background")

var modifier := 600

const PAUSE_INCREMENT := 5000
var pauseVal := PAUSE_INCREMENT
var paused := false

func _ready():
	$Height/High.text = str(Global.highScore)
	if Global.shame: $Height/High.text = str($Height/High.text, "?")

func _process(_delta):
	change_background()

func pause():
	paused = true
	$Height/Current.text = str(floor(pauseVal))
	get_node("../Spawner").spawn_boss()

func unpause(value): #player height on boss kill
	#print(value)
	paused = false
	modifier = value + pauseVal
	pauseVal += PAUSE_INCREMENT

func set_height(value):
	if !paused:
		var heightVal : float = abs(modifier - min(modifier, value))
		if heightVal < pauseVal:
			$Height/Current.text = str(floor(heightVal))
		else: pause()

func get_height() -> int:
	return int($Height/Current.text)

func set_fuel(value, threshold, jumps, maxJumps):
	if value > 100: $FuelBar.max_value = value
	elif $FuelBar.max_value > 100: $FuelBar.max_value = 100
	$FuelBar.value = value
	$FuelBar/Text.text = str(value)
	if value < threshold or jumps >= maxJumps: $FuelBar.modulate = Color(1,0,0,1)
	elif value < threshold*2 or jumps == maxJumps - 1: $FuelBar.modulate = Color(1,1,0,1)
	else: $FuelBar.modulate = Color(1,1,1,1)

func update_health(value, isHeal):
	if isHeal: $Health.get_child(value-1).visible = true
	else: $Health.get_child(value).visible = false

func set_item(hasItem):
	$Consumable.visible = hasItem

func change_background():
	var fadeVal : int = get_height() * 235 / 6500
	var bgRed : float = max(.05, (135 - fadeVal) / 255.0)
	var bgBlue : float = max(.12, (206 - fadeVal) / 255.0)
	var bgGreen : float = max(.2, (235 - fadeVal) / 255.0)
	Background.color = Color(bgRed, bgBlue, bgGreen, 1)

func update_weapons():
	
	# Update weapon info
	for _w in Global.player.weapon_slot.size():
		var _weapon_id = Global.player.weapon_slot[_w]
		
		# Update current weapon name
		if _w == 0:
			$"Weapon slots".get_child(_w).get_node("Weapon Name").text = Global.player.get_node("Weapon").get_child(_weapon_id).NAME
			pass
		
		# Change weapon sprite
		if _weapon_id >= 0:
			$"Weapon slots".get_child(_w).get_node("Sprite2D").texture = load(Global.player.get_node("Weapon").get_child(_weapon_id).ITEM_SPRITE)
			pass
		# Reset sprite
		else:
			$"Weapon slots".get_child(_w).get_node("Sprite2D").texture = null
			pass
		
		pass
	
	pass

func update_ammo():
	
	# reset first
	$Ammo.text = ""
	
	# Show a string of characters to represent ammo
	for _ammo in Global.player.weapon_ammo:
		$Ammo.text += str(Global.player.get_node("Weapon").get_child(Global.player.weapon_slot[0]).AMMO_ASCII)
		pass
	
	# Show max ammo capacity
	$Ammo.text += " / " + str(Global.player.weapon_ammo_max)
	
	
	pass
