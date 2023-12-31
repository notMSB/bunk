extends CanvasLayer

@onready var Background := get_node("../BackgroundLayer/Background")

func _ready():
	$Height/High.text = str(Global.score)
	if Global.shame: $Height/High.text = str($Height/High.text, "?")

func _process(_delta):
	change_background()

func set_height(modifier, value):
	var heightVal : float = abs(modifier - min(modifier, value))
	$Height/Current.text = str(floor(heightVal))

func get_height() -> int:
	return int($Height/Current.text)

func set_fuel(value, threshold, jumps, maxJumps):
	$FuelBar.value = value
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
