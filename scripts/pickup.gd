extends Area2D

var player : CharacterBody2D

enum d {fuel, health, grenade, weapon}
var dIndex : int

func setup(p):
	player = p
	p.healthWeight += get_health_weight()
	p.fuelWeight += get_fuel_weight()
	p.grenadeWeight += get_grenade_weight()
	p.weaponWeight += get_weapon_weight()
	
	# Get random number
	var rando = randi() % (p.healthWeight + p.fuelWeight + p.grenadeWeight + p.weaponWeight)
	
	# Figure out what was picked by subtracting weights to find the range it was in
	rando -= p.healthWeight
	if rando < 0: 
		dIndex = d.health
		$PickupSprite.texture = preload("res://assets/sprites/health.png")
		p.healthWeight = 0
		return
	rando -= p.fuelWeight
	if rando < 0: 
		dIndex = d.fuel
		$PickupSprite.texture = preload("res://assets/sprites/fuel.png")
		p.fuelWeight = 0
		return
	
	rando -= p.weaponWeight
	if rando < 0:
		dIndex = d.weapon
		p.weaponWeight = 0
		# Spawn special weapon pickup
		# It is it's own object so it's handled differently. Players can choose to pick it up, as a button is required
		var _pickup = load("res://scenes/weapon_pickup.tscn").instantiate()
		
		# Had some problems spawning the item pickup on the platform...
		# It would spawn, but would start sliding around for some reason. 
		# Setting velocity to 0 didn't fix it. Not sure what's going on.
		# So I just reparented to the spawner controller and spawned it above the platform. 
		# This is likely to cause problems later as it might fall through or not be reliable. 
		self.get_parent().get_parent().add_child(_pickup)	# Set parent to spawner, not platform
		_pickup.position.y = get_parent().position.y - 32 # 45
		_pickup.position.x = get_parent().position.x
		queue_free()
		return
	
	# Default to a grenade item
	rando -= p.grenadeWeight
	if rando < 0:
		dIndex = d.grenade
		$PickupSprite.texture = preload("res://assets/sprites/grenade.png")
		p.grenadeWeight = 0
		return

func get_health_weight():
	if player.health == 1: return 100
	elif player.health == 2: return 60
	else: return 15

func get_fuel_weight():
	if player.mobile: return 100
	if player.fuel < 10: return 100
	if player.fuel < 50: return 60
	if player.fuel < 75: return 40
	if player.fuel < 100: return 10
	return 0

func get_grenade_weight():
	if player.mobile: return 50
	if player.hasItem == false: return 60
	else: return 20

func get_weapon_weight():
	
	return 3
	
	pass

func _on_body_entered(_body):
	if player.mobile:
		match dIndex:
			d.fuel: player.change_fuel(100); 		var _text = Global.spawn_notif_text("Fuel!", self); _text.set_style_fast_tiny()
			d.health: player.heal(1); 				var _text = Global.spawn_notif_text("Health!", self); _text.set_style_fast_tiny()
			d.grenade: player.get_node("Item").get_child(0).use(); 	var _text = Global.spawn_notif_text("Grenade!", self); _text.set_style_fast_tiny()
	else:
		match dIndex:
			d.fuel: player.change_fuel(25); 		var _text = Global.spawn_notif_text("Fuel!", self); _text.set_style_fast_tiny()
			d.health: player.heal(1); 				var _text = Global.spawn_notif_text("Health!", self); _text.set_style_fast_tiny()
			d.grenade: player.change_item(true); 	var _text = Global.spawn_notif_text("Grenade!", self); _text.set_style_fast_tiny()
	queue_free()
