extends Area2D

var player : CharacterBody2D

enum d {fuel, health, grenade}
var dIndex : int

func setup(p):
	player = p
	p.healthWeight += get_health_weight()
	p.fuelWeight += get_fuel_weight()
	p.grenadeWeight += get_grenade_weight()
	
	var rando = randi() % (p.healthWeight + p.fuelWeight + p.grenadeWeight)
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
	dIndex = d.grenade
	$PickupSprite.texture = preload("res://assets/sprites/grenade.png")
	p.grenadeWeight = 0

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

func _on_body_entered(_body):
	if player.mobile:
		match dIndex:
			d.fuel: player.change_fuel(100)
			d.health: player.heal(1)
			d.grenade: player.get_node("Item").get_child(0).use()
	else:
		match dIndex:
			d.fuel: player.change_fuel(25)
			d.health: player.heal(1)
			d.grenade: player.change_item(true)
	queue_free()
