extends Area2D

enum d {fuel, health, grenade}

var player : CharacterBody2D

var dIndex : int

func setup(p):
	player = p
	var healthWeight := 0
	var fuelWeight := 1
	var grenadeWeight := 0
	if player.health == 1: healthWeight = 100
	elif player.health == 2: healthWeight = 60
	if player.fuel < 10: fuelWeight = 100
	elif player.fuel < 50: fuelWeight = 60
	elif player.fuel < 75: fuelWeight = 40
	elif player.fuel < 100: fuelWeight = 10
	if player.hasItem == false: grenadeWeight = 60
	var rando = randi() % (healthWeight + fuelWeight + grenadeWeight)
	rando -= healthWeight
	if rando < 0: 
		dIndex = d.health
		$PickupSprite.texture = preload("res://assets/sprites/health.png")
		return
	rando -= fuelWeight
	if rando < 0: 
		dIndex = d.fuel
		$PickupSprite.texture = preload("res://assets/sprites/fuel.png")
		return
	dIndex = d.grenade
	$PickupSprite.texture = preload("res://assets/sprites/grenade.png")

func _on_body_entered(_body):
	match dIndex:
		d.fuel: player.change_fuel(20)
		d.health: player.heal(1)
		d.grenade: player.change_item(true)
	queue_free()
