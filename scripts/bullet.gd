extends Area2D

var direction = Vector2()
var speed = 750
var damage

func fire(goalPos, startPos, weaponDamage):
	damage = weaponDamage
	global_position = startPos
	direction = (goalPos - startPos).normalized()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.collision_layer == 2: #damage enemy
		if body.health > 0: body.take_damage(damage)
	if body.collision_layer != 1: #ignore player, delete on everything else
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
