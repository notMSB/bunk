extends Node2D

@export var Projectile : PackedScene

const PROJECTILES := 7

var degs := 10.0
var drift : float = degs/((PROJECTILES-1)/2.0)

func fire(goalPos, startPos, weaponDamage):
	global_position = startPos
	for i in PROJECTILES:
		if i > 0: degs -= drift
		var shot = Projectile.instantiate()
		add_child(shot)
		shot.fire(goalPos, startPos, weaponDamage)
		shot.rotate_direction(degs)
