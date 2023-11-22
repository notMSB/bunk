extends Node2D

var player : CharacterBody2D
@onready var enemy = get_parent()

var changed := false

const CHARGE_DEFAULT := 5
var chargeTime := CHARGE_DEFAULT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !changed and  !enemy.killTimerSet and enemy.global_position.distance_to(player.global_position) < 400:
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity.x = direction.x
		enemy.velocity.y = direction.y
		enemy.velocity *= 200
		changed = true
	if changed:
		chargeTime -= delta
		if chargeTime <= 0 and enemy.global_position.distance_to(player.global_position) > 300:
			changed = false
			chargeTime = CHARGE_DEFAULT

func setup(p):
	player = p
