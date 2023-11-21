extends CanvasLayer

@onready var Background := get_node("../BackgroundLayer/Background")

func _ready():
	$Height/High.text = str(Global.score)

func _process(_delta):
	change_background()

func set_height(modifier, value):
	var heightVal : float = abs(modifier - min(modifier, value))
	$Height/Current.text = str(floor(heightVal))

func get_height() -> int:
	return int($Height/Current.text)

func set_fuel(value):
	$FuelBar.value = value

func change_background():
	var fadeVal : int = get_height() * 235 / 6500
	var bgRed : float = max(.05, (135 - fadeVal) / 255.0)
	var bgBlue : float = max(.12, (206 - fadeVal) / 255.0)
	var bgGreen : float = max(.2, (235 - fadeVal) / 255.0)
	Background.color = Color(bgRed, bgBlue, bgGreen, 1)
