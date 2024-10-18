extends Node2D


var animation_in_complete := false
var juice_bounce_strength := 0.4	# Multiplied to velocity on bounce
var juice_bounce_velocity := 0.0	# Current speed
var juice_bounce_gravity := 6000.0		# added speed
var juice_bounce_speed_snap_ground := 30.0
var juice_bounces := 0
var juice_bounce_max := 10

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set menu data
	$"CanvasLayer/Score Value".text = str(Global.runScore)
	$"CanvasLayer/High Score Value".text = str(Global.highScore)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# apply juice effects
	if !animation_in_complete: animate_in(delta)
	
	pass


func _on_restart_button_up():
	
	if !animation_in_complete: return
	
	#Global.player.usedWeapon = weaponIndex
	get_tree().call_deferred("reload_current_scene")
	
	queue_free()
	pass # Replace with function body.


func _on_main_menu_button_up():
	
	if !animation_in_complete: return
	
	# Exit game, go back to main menu
	#get_tree().unload_current_scene()
	#var menu = load("res://scenes/menu.tscn").instantiate()
	#get_tree().root.add_child(menu)
	
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
	queue_free()
	pass # Replace with function body.

func animate_in(delta):
	
	# apply speed over time
	juice_bounce_velocity += juice_bounce_gravity * delta
	
	# Move canvas
	$CanvasLayer.offset.y += juice_bounce_velocity * delta
	
	# Bounce
	if $CanvasLayer.offset.y >= 0:
		
		# Snap to bottom
		$CanvasLayer.offset.y = 0
		
		# Bounce
		# Backup system to get it to stop bouncing in case physics get weird
		if juice_bounce_velocity > juice_bounce_speed_snap_ground && juice_bounces < juice_bounce_max:
			juice_bounce_velocity = -juice_bounce_velocity * juice_bounce_strength
			juice_bounces += 1
			print("Bounce")
		# End bouncing, menu done
		else:
			juice_bounce_velocity = 0
			animation_in_complete = true
			print("Ending bounce")
	
	
	
	pass
