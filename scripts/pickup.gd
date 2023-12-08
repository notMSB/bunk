extends Area2D

var player : CharacterBody2D

enum d {fuel, health, grenade}
var dIndex : int

var healthWeight := 0
var fuelWeight := 0
var grenadeWeight := 0

func setup(p):
	player = p
	healthWeight += get_health_weight()
	fuelWeight += get_fuel_weight()
	grenadeWeight += get_grenade_weight()
	
	var rando = randi() % (healthWeight + fuelWeight + grenadeWeight)
	rando -= healthWeight
	if rando < 0: 
		dIndex = d.health
		$PickupSprite.texture = preload("res://assets/sprites/health.png")
		healthWeight = 0
		return
	rando -= fuelWeight
	if rando < 0: 
		dIndex = d.fuel
		$PickupSprite.texture = preload("res://assets/sprites/fuel.png")
		fuelWeight = 0
		return
	dIndex = d.grenade
	$PickupSprite.texture = preload("res://assets/sprites/grenade.png")
	grenadeWeight = 0

func get_health_weight():
	if player.health == 1: return 100
	elif player.health == 2: return 60
	else: return 15

func get_fuel_weight():
	if player.fuel < 10: return 100
	elif player.fuel < 50: return 60
	elif player.fuel < 75: return 40
	else: return 10

func get_grenade_weight():
	if player.hasItem == false: return 60
	else: return 20

func _on_body_entered(_body):
	match dIndex:
		d.fuel: player.change_fuel(25)
		d.health: player.heal(1)
		d.grenade: player.change_item(true)
	queue_free()
