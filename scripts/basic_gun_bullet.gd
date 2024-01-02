extends Node2D

@export var Projectile : PackedScene

@onready var gun = get_node("../../Weapon/basic_gun")

func fire(goalPos, startPos, weaponDamage, pierce):
	var shot = Projectile.instantiate()
	add_child(shot)
	shot.fire(goalPos, startPos, weaponDamage, pierce)
	var rando : int = 0 if gun.drift == 0 else randi() % gun.drift
	var dir : int = 1 if randi() % 2 == 1 else -1
	shot.rotate_direction(rando * dir / 100)
	gun.drift += 100
