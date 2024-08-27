extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var weapon_id = 0

func _ready() -> void:
	
	await get_tree().create_timer(0.1).timeout # debug
	generate_new_weapon()
	
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

func generate_new_weapon():
	
	# Pick a random weapon when spawned
	var rng = RandomNumberGenerator.new()
	weapon_id = rng.randi_range(0, Global.player.weapons_total - 1)
	
	# Temp. Set label on this pickup to match player's weapon name.
	
	$"Weapon Name".text = Global.player.get_node("Weapon").get_child(weapon_id).get_name()
	

func _on_weapon_pickup_area_body_entered(body):
	
	#print("Body entered: " + str(body.get_name()))
	
	if body == Global.player:
		body.weapon_pickup_instance = self
		pass
	
	
	pass # Replace with function body.


func _on_weapon_pickup_area_body_exited(body):
	
	if body == Global.player:
		body.weapon_pickup_instance = null
		pass
	
	pass # Replace with function body.
