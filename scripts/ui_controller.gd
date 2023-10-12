extends CanvasLayer

func _ready():
	$Height/High.text = str(Global.score)

func set_height(modifier, value):
	var heightVal = abs(modifier - min(modifier, value))
	$Height/Current.text = str(floor(heightVal))

func get_height():
	return int($Height/Current.text)

func set_fuel(value):
	$FuelBar.value = value
