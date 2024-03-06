extends Node2D

@export var Projectile : PackedScene

const COOLDOWN = .35
const DAMAGE = 10
const PIERCE := .0
const ALT_PIERCE := .05

func get_pierce():
	if get_parent().get_parent().crouched: return ALT_PIERCE
	return PIERCE

func shot_boost(mousePos, playerPos, force):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
