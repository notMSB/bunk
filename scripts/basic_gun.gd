extends Node2D

@export var Projectile : PackedScene

const COOLDOWN := .11
const DAMAGE := 2
const PIERCE := .2

const DRIFT_RESET := .22
var currentReset := .0

const MAX_DRIFT := 13.5
var drift := .0

func _process(delta):
	currentReset -= delta
	if currentReset <= 0: drift = 0

func set_reset():
	currentReset = DRIFT_RESET

func increase_drift(amount):
	drift = min(drift + amount, MAX_DRIFT)

func shot_boost(mousePos, playerPos):
	var direction = (playerPos - mousePos).normalized()
	return Vector2(500, 500) * direction
