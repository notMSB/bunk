extends Area2D

var direction := Vector2()
var speed := 900
var damage : int

var damageMask : int
var ignoreMask : int

var pierceTimer := .0
var canPierce := true

var time_speed := 1.0

func _ready():
	Global.player.get_node("Item/grenade").enemy_projectiles_destroyed.connect(projectiles_destroyed) 
	Global.player.get_node("Item/grenade").time_freeze.connect(time_freeze) 
	
	if Global.player.get_node("Item/grenade").time_freeze_active: time_freeze(Global.player.get_node("Item/grenade").time_speed)
	
	pass

func projectiles_destroyed():
	queue_free()
	pass

func time_freeze(_time_speed):
	time_speed = _time_speed

func fire(goalPos, startPos, weaponDamage, pierce, mask = 2, speedMod = 1):
	if pierce != 0: #0 pierce is infinite pierce
		pierceTimer = pierce
		$Sprite2D.modulate = Color(1,1,0,1)
	speed = speed * speedMod
	damageMask = mask
	ignoreMask = 65 if mask == 2 else 2
	damage = weaponDamage
	global_position = startPos
	direction = (goalPos - startPos).normalized()

func rotate_direction(degree):
	direction = direction.rotated(deg_to_rad(degree))

func _process(delta):
	
	delta *= time_speed
	
	position += direction * speed * delta
	if pierceTimer > 0: 
		pierceTimer -= delta
		if pierceTimer <= 0:
			canPierce = false
			$Sprite2D.modulate = Color(0,0,0,1)

func _on_body_entered(body):
	if body.collision_layer == damageMask: #damage valid target
		if body.health > 0: body.take_damage(damage)
	if body.collision_layer != ignoreMask and !canPierce: #ignore player, delete on everything else
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if get_parent().name != "Projectiles": get_parent().queue_free()
	else: queue_free()
