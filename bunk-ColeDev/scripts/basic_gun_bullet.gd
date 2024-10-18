extends Node2D

@export var Projectile : PackedScene

@onready var gun = get_node("../../Weapon/basic_gun")

func fire(goalPos, startPos, weaponDamage, pierce):
	var shot = Projectile.instantiate()
	add_child(shot)
	shot.fire(goalPos, startPos, weaponDamage, pierce)
	shot.rotate_direction(randf_range(gun.drift * -1, gun.drift))
	gun.increase_drift(1)
	gun.set_reset()
