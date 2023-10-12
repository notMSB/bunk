extends Node2D

@export var Explosion : PackedScene

var direction = Vector2()
var speed = 500
var damage

func fire(goalPos, startPos, weaponDamage):
	damage = weaponDamage
	global_position = startPos
	direction = (goalPos - startPos).normalized()
	rotation = direction.angle()
	position += direction * 4 * scale.x

func explode(rocketHit):
	var boom = Explosion.instantiate()
	get_parent().call_deferred("add_child", boom)
	boom.position = position
	boom.setup(damage, rocketHit)
	queue_free()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.collision_layer != 1: #ignore player, delete on everything else
		explode(body)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
