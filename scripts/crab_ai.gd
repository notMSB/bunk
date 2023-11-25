extends Node2D

var player : CharacterBody2D
@onready var enemy = get_parent()

var changed := false
var recharge = false

const CHARGE_DEFAULT := 5
var chargeTime := CHARGE_DEFAULT

func _process(delta):
	if !changed and  !enemy.killTimerSet and enemy.global_position.distance_to(player.global_position) < 400:
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity = direction * 180
		changed = true
	if changed and recharge:
		chargeTime -= delta
		if chargeTime <= 0 and enemy.global_position.distance_to(player.global_position) > 350:
			changed = false
			chargeTime = CHARGE_DEFAULT

func setup(p):
	player = p
	if p.UI.get_height() > 1500: recharge = true
