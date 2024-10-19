extends Area2D

@onready var player : CharacterBody2D = Global.player


var pickup = {
	Global.PICKUP.fuel: {
		name = "fuel"
	}, 
	Global.PICKUP.health: {
		name = "health"
	}, 
	Global.PICKUP.weapon: {
		name = "weapon"
	}, 
	Global.PICKUP.grenade: {
		name = "Grenade",
		sprite = "res://assets/sprites/grenade.png",
		spawn_weight = 1.0
	}, 
	Global.PICKUP.EMP: {
		name = "EMP",
		displayname = "EMP",
		spawn_weight = 1.0
		#sprite = "res://assets/sprites/grenade.png"
	}, 
	Global.PICKUP.Photon_Barrier: {
		name = "Photon Barrier",
		displayname = "PB",
		spawn_weight = 2.0
		#sprite = "res://assets/sprites/grenade.png"
	}, 
	Global.PICKUP.Time_Freeze: {
		name = "Time Freeze",
		displayname = "TF",
		spawn_weight = 0.5
		#sprite = "res://assets/sprites/grenade.png"
	}, 
	Global.PICKUP.Portal_Trinket: {
		name = "Portal Trinket",
		displayname = "PT",
		spawn_weight = 1.0
		#sprite = "res://assets/sprites/grenade.png"
	}
}
var pickup_index : int

enum SPAWN_SOURCE {
	Platform,
	Enemy
}

var healthWeight 	= 0
var fuelWeight 		= 0
var weaponWeight 	= 0
var gadgetWeight 	= 0
var reward_source := SPAWN_SOURCE.Platform

func setup(_player, _spawn_source = SPAWN_SOURCE.Platform):
	# Set player object
	player = _player
	reward_source = _spawn_source
	
	healthWeight 	+= get_health_weight()
	fuelWeight 		+= get_fuel_weight()
	weaponWeight 	+= get_weapon_weight()
	gadgetWeight 	+= get_gadget_weight()
	
	# Get random number
	var rando = randi() % (healthWeight + fuelWeight + gadgetWeight + weaponWeight)
	
	# Figure out what was picked by subtracting weights to find the range it was in
	rando -= healthWeight
	if rando <= 0 && healthWeight > 0: 
		pickup_index = Global.PICKUP.health
		$PickupSprite.texture = preload("res://assets/sprites/health.png")
		healthWeight = 0
		return
	rando -= fuelWeight
	if rando <= 0 && fuelWeight > 0: 
		pickup_index = Global.PICKUP.fuel
		$PickupSprite.texture = preload("res://assets/sprites/fuel.png")
		fuelWeight = 0
		return
	
	rando -= weaponWeight
	if rando <= 0 && weaponWeight > 0:
		pickup_index = Global.PICKUP.weapon
		weaponWeight = 0
		# Spawn special weapon pickup
		# It is it's own object so it's handled differently. Players can choose to pick it up, as a button is required
		var _pickup = load("res://scenes/weapon_pickup.tscn").instantiate()
		
		# Had some problems spawning the item pickup on the platform...
		# It would spawn, but would start sliding around for some reason. 
		# Setting velocity to 0 didn't fix it. Not sure what's going on.
		# So I just reparented to the spawner controller and spawned it above the platform. 
		# This is likely to cause problems later as it might fall through or not be reliable. 
		
		if(reward_source == SPAWN_SOURCE.Platform):
			self.get_parent().get_parent().add_child(_pickup)	# Set parent to spawner, not platform
		else:
			self.get_parent().add_child(_pickup)	# Set parent to spawner, not platform
		_pickup.global_position.y = get_parent().global_position.y - 64 # 32
		_pickup.global_position.x = get_parent().global_position.x
		queue_free()
		return
	
	# Default to a grenade item
	rando -= gadgetWeight
	if rando <= 0 && gadgetWeight > 0:
		
		# Get all weights
		var _gadget_weight_total = 0.0
		for key in Global.PICKUP.length:
			# skip all entries until we reach gadgets
			if key < Global.PICKUP.grenade: continue;
			_gadget_weight_total += pickup[key].spawn_weight
			pass
		
		# Randomize weight chosen, and pick gadget based on that
		var _gadget_weight_chosen = randf_range(0, _gadget_weight_total)
		for key in Global.PICKUP.length:
			if key < Global.PICKUP.grenade: continue;
			_gadget_weight_chosen -= pickup[key].spawn_weight
			
			if _gadget_weight_chosen <= 0:
				pickup_index = key
				break;
		
		
		#pickup_index = randi_range(Global.PICKUP.grenade, Global.PICKUP.length-1)
		
		# Set sprite
		if pickup[pickup_index].has("sprite"):
			$PickupSprite.texture = load(pickup[pickup_index].sprite)
		# set display name
		elif pickup[pickup_index].has("displayname"):
			$DisplayName.text = pickup[pickup_index].displayname
			$PickupSprite.texture = null
		else:
			$DisplayName.text = pickup[pickup_index].name
			$PickupSprite.texture = null
		
		gadgetWeight = 0
		return

func get_health_weight():
	
	# for enemies, don't spawn
	if(reward_source == SPAWN_SOURCE.Enemy): return 0
	
	if player.health == 1: return 100
	elif player.health == 2: return 60
	else: return 15

func get_fuel_weight():
	
	# for enemies, don't spawn
	if(reward_source == SPAWN_SOURCE.Enemy): return 0
	
	if player.mobile: return 100
	if player.fuel < 10: return 100
	if player.fuel < 50: return 80 #60
	if player.fuel < 75: return 60 #40
	if player.fuel < 100: return 40 #10
	return 30

func get_gadget_weight():
	
	# for platforms, don't spawn
	if(reward_source == SPAWN_SOURCE.Platform): return 0
	
	if player.mobile: return 50
	if player.hasItem == false: return 60
	else: return 20

func get_weapon_weight():
	return 3

func _on_body_entered(_body):
	if player == null: return
	
	if player.mobile:
		match pickup_index:
			Global.PICKUP.fuel: player.change_fuel(100); 		var _text = Global.spawn_notif_text("Fuel!", self); _text.set_style_fast_tiny()
			Global.PICKUP.health: player.heal(1); 				var _text = Global.spawn_notif_text("Health!", self); _text.set_style_fast_tiny()
			_: # Gadgets
				player.change_item(pickup_index); print("Player pickup item: " + str(pickup_index))
				player.get_node("Item").get_child(0).use(); 
				var _text = Global.spawn_notif_text(pickup[pickup_index].name + "!", self); _text.set_style_fast_tiny()
	else:
		match pickup_index:
			Global.PICKUP.fuel: player.change_fuel(25); 		var _text = Global.spawn_notif_text("Fuel!", self); _text.set_style_fast_tiny()
			Global.PICKUP.health: player.heal(1); 				var _text = Global.spawn_notif_text("Health!", self); _text.set_style_fast_tiny()
			_: # Gadgets
				player.change_item(pickup_index); 	print("Player pickup item: " + str(pickup_index))
				var _text = Global.spawn_notif_text(pickup[pickup_index].name + "!", self); _text.set_style_fast_tiny()
	queue_free()
