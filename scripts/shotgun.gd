extends Node2D

@export var Projectile : PackedScene

const NAME = "Shotgun"
const COOLDOWN = .5
const DAMAGE = 1
const PIERCE = .15
const RELOAD_TIME := 1.5
const MAGAZINE_SIZE := 2
const ITEM_SPRITE := "res://assets/sprites/shotgun.png"
const AMMO_ASCII := " []"

func get_pierce():
	return PIERCE

func shot_boost(mousePos, playerPos, force):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
