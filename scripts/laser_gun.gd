extends Node2D

@export var Projectile : PackedScene

const NAME = "Laser Gun"
const COOLDOWN := .4
const DAMAGE := 3
const PIERCE := .0
const RELOAD_TIME := .65
const MAGAZINE_SIZE := 8
const ITEM_SPRITE := "res://assets/sprites/laser gun.png"
const AMMO_ASCII := "l"

func get_pierce():
	return PIERCE

func shot_boost(mousePos, playerPos, force):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
