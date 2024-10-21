extends Node2D


# Parameters
var lifetime := 0.5
var scale_end := Vector2(70, 70)
var size_lerp := 5

# instantiate
var lifetime_alarm := 0.0
var lifetime_alarm_max := 0.0
var lifetime_normal := 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	set_lifetime(lifetime)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if lifetime_alarm > 0:
		lifetime_alarm = max(0, lifetime_alarm - delta)
		lifetime_normal = lifetime_alarm / lifetime_alarm_max
		
		# end alarm
		if lifetime_alarm <= 0:
			queue_free()
	
	## scale effect
	#$RadialEffect.texture.width 	= lerp($RadialEffect.texture.width, size_end, size_lerp * delta)
	#$RadialEffect.texture.height 	= lerp($RadialEffect.texture.height, size_end, size_lerp * delta)
	$RadialEffect.scale 	= lerp($RadialEffect.scale, scale_end, size_lerp * delta)
	
	pass

func set_lifetime(_new_lifetime):
	lifetime_alarm_max = _new_lifetime
	lifetime_alarm = lifetime_alarm_max
	lifetime_normal = 1.0
