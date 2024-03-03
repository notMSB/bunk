extends Node2D

@export var Explosion : PackedScene

var direction := Vector2()
var speed := 950
var damage : int

var pierceTimer := .0
var canPierce := false

func fire(goalPos, startPos, weaponDamage, pierce):
	if pierce != 0: #0 pierce is infinite pierce
		canPierce = true
		pierceTimer = pierce
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
	if pierceTimer > 0: 
		pierceTimer -= delta
		if pierceTimer <= 0:
			canPierce = false

func _on_body_entered(body):
	if body.collision_layer != 65 and !canPierce: #ignore player, delete on everything else
		explode(body)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
