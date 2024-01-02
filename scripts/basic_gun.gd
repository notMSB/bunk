extends Node2D

@export var Projectile : PackedScene

const COOLDOWN := .11
const DAMAGE := 2
const PIERCE := .1

const MAX_DRIFT := 15.0
var drift := .0

func _process(_delta):
	drift = clamp(drift - .035, 0, MAX_DRIFT)
