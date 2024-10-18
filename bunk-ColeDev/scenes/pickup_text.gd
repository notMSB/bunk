extends Node2D


@export var life_time : float = 1.5	## Time text is shown
@export var life_time_fast : float = 0.75	## Time text is shown
var life_time_alarm = 0
@export var decay_time : float = 0.25 ## Time text takes to fade away
var decay_time_alarm = 0

var float_y_speed = -0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	
	life_time_alarm = life_time
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Decay timers
	if decay_time_alarm > 0:
		decay_time_alarm = max(0, decay_time_alarm - delta)
		
		# Fade out text
		modulate.a = lerp(0, 1, decay_time_alarm / decay_time)
		
		if decay_time_alarm == 0:
			queue_free()
			pass
	
	if life_time_alarm > 0:
		life_time_alarm = max(0, life_time_alarm - delta)
		
		if life_time_alarm == 0:
			decay_time_alarm = decay_time
			pass
	
	position.y += float_y_speed
	

func set_text(_new_text):
	
	$Label.text = str(_new_text)
	
	pass

func set_style_fast_tiny():
	
	# Sets text to be tiny and fast
	
	self.scale = Vector2(0.5, 0.5)
	life_time_alarm = life_time_fast
	
	pass
