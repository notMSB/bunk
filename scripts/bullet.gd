extends Area2D

var direction := Vector2()
var speed := 900
var damage : int

var damageMask : int
var ignoreMask : int

func fire(goalPos, startPos, weaponDamage, mask = 2, speedMod = 1):
	speed = speed * speedMod
	damageMask = mask
	ignoreMask = 1 if mask == 2 else 2
	damage = weaponDamage
	global_position = startPos
	direction = (goalPos - startPos).normalized()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.collision_layer == damageMask: #damage valid target
		if body.health > 0: body.take_damage(damage)
	if body.collision_layer != ignoreMask: #ignore player, delete on everything else
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
