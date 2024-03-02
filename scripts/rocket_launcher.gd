extends Node2D

@export var Projectile : PackedScene

const COOLDOWN = .35
const DAMAGE = 10
const PIERCE := .0

func shot_boost(mousePos, playerPos, grounded):
	var force = 500 if grounded else 400
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
