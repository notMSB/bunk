extends Node2D

@export var Projectile : PackedScene

const COOLDOWN := .11
const DAMAGE := 2
const PIERCE := .1

const DRIFT_RESET := .22
var currentReset := .0

const MAX_DRIFT := 15.0
var drift := .0

func _process(delta):
	currentReset -= delta
	if currentReset <= 0: drift = 0

func set_reset():
	currentReset = DRIFT_RESET
