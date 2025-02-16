extends Node2D

@export var Projectile : PackedScene

const NAME = "No weapon"
const COOLDOWN := .11
const DAMAGE := 0
const RELOAD_TIME := 1.25
const MAGAZINE_SIZE := 0
const PIERCE := 0
const ITEM_SPRITE := ""
const AMMO_ASCII := "i"

const DRIFT_RESET := .22
var currentReset := .0

const MAX_DRIFT := 13.5
var drift := .0

func get_pierce():
	return PIERCE

func _process(delta):
	currentReset -= delta
	if currentReset <= 0: drift = 0

func set_reset():
	currentReset = DRIFT_RESET

func increase_drift(amount):
	drift = min(drift + amount, MAX_DRIFT)

func shot_boost(mousePos, playerPos, force):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(force, force) * direction
