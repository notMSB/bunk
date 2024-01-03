extends Area2D

var direction := Vector2()
var speed := 900
var damage : int

var damageMask : int
var ignoreMask : int

var pierceTimer : float

func fire(goalPos, startPos, weaponDamage, pierce, mask = 2, speedMod = 1):
	pierceTimer = pierce
	if pierceTimer > 0: $Sprite2D.modulate = Color(1,1,0,1)
	speed = speed * speedMod
	damageMask = mask
	ignoreMask = 65 if mask == 2 else 2
	damage = weaponDamage
	global_position = startPos
	direction = (goalPos - startPos).normalized()

func rotate_direction(degree):
	direction = direction.rotated(deg_to_rad(degree))

func _process(delta):
	position += direction * speed * delta
	if pierceTimer > 0: 
		pierceTimer -= delta
		if pierceTimer <= 0: $Sprite2D.modulate = Color(0,0,0,1)

func _on_body_entered(body):
	if body.collision_layer == damageMask: #damage valid target
		if body.health > 0: body.take_damage(damage)
	if body.collision_layer != ignoreMask and pierceTimer <= 0: #ignore player, delete on everything else
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if get_parent().name != "Projectiles": get_parent().queue_free()
	else: queue_free()
