extends Area2D

var direction := Vector2()
var damage : int

func fire(goalPos, startPos, weaponDamage):
	damage = weaponDamage
	global_position = startPos
	direction = (goalPos - startPos).normalized()
	rotation = direction.angle()
	position += direction * 4 * scale.x

func _process(_delta):
	$Sprite2D.modulate.a -= .02
	if $Sprite2D.modulate.a <= 0: queue_free()

func _on_body_entered(body):
	if body.collision_layer == 2: #damage enemy
		if body.health > 0: body.take_damage(damage)
