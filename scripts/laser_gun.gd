extends Node2D

@export var Projectile : PackedScene

const COOLDOWN := .4
const DAMAGE := 3
const PIERCE := .0

func get_pierce():
	return PIERCE

func shot_boost(mousePos, playerPos, force):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
