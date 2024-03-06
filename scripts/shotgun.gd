extends Node2D

@export var Projectile : PackedScene

const COOLDOWN = .5
const DAMAGE = 1
const PIERCE = .15

func get_pierce():
	return PIERCE

func shot_boost(mousePos, playerPos, force):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
