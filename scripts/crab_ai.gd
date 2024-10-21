extends Node2D

var player : CharacterBody2D
@onready var enemy = get_parent()

var changed := false
var recharge = false
var seeking_player = false
var seek_player_trigger_distance := 400.0

const CHARGE_DEFAULT := 5
var chargeTime := CHARGE_DEFAULT

var time_speed = 1.0

func _process(delta):
	delta *= time_speed
	if delta == 0: return
	
	# Decide when to seek player
	if !seeking_player && enemy.global_position.distance_to(player.global_position) < seek_player_trigger_distance:
		seeking_player = true
		pass
	
	if !changed and  !enemy.killTimerSet and seeking_player:
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

func on_enemy_damaged():
	seeking_player = true;
	pass
