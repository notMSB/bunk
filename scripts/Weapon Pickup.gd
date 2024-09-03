extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var weapon_id : int = -1

func _ready() -> void:
	
	$"Pickup Prompt".hide()
	
	await get_tree().create_timer(0.001).timeout # debug
	# Generate a new weapon if we aren't set to one. 
	if(weapon_id == -1):
		generate_new_weapon()
	# Ensure ID is within weapons total
	else:
		if weapon_id >= Global.player.weapons_total: print("Error: Weapon id set greater than max. Capping to max. ") 
		weapon_id = clamp(weapon_id, 0, Global.player.weapons_total)
		update_draw()
	
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		pass
	else:
		velocity.y = 0
		pass
	
	#velocity.x = 0
	#velocity.x -= get_floor_velocity().x
	
	move_and_slide()

func generate_new_weapon():
	
	var rng = RandomNumberGenerator.new()
	
	# Pick a random weapon when spawned
	# Be sure to pick a weapon that the player is not equipped with
	while weapon_id == -1 || Global.player.weapon_slot.has(weapon_id):
		weapon_id = rng.randi_range(0, Global.player.weapons_total - 1)
	
	update_draw()

func update_draw():
	
	# Temp. Set label on this pickup to match player's weapon name.
	$"Weapon Name".text = Global.player.get_node("Weapon").get_child(weapon_id).NAME
	
	pass

func picked_up():
	
	# Clears object by being picked up
	
	
	
	# Spawn it
	
	Global.spawn_notif_text("Got " + $"Weapon Name".text + "!", self)
	
	# Delete self
	queue_free()
	pass

func _on_weapon_pickup_area_body_entered(body):
	
	#print("Body entered: " + str(body.get_name()))
	
	if body == Global.player:
		body.weapon_pickup_instance = self
		$"Pickup Prompt".show()
		pass
	
	
	pass # Replace with function body.


func _on_weapon_pickup_area_body_exited(body):
	
	if body == Global.player:
		body.weapon_pickup_instance = null
		$"Pickup Prompt".hide()
		pass
	
	pass # Replace with function body.
