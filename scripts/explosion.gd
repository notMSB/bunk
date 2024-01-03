extends Area2D

const MAXLIFETIME = 0.2
var lifetime = MAXLIFETIME
var damage : int
var hitBody

func _process(delta):
	lifetime -= delta
	if lifetime <= 0: queue_free()

func setup(weaponDamage, causeBody):
	damage = weaponDamage
	hitBody = causeBody

func _on_body_entered(body):
	if body.collision_layer != 65: #ignore player, delete on everything else
		if body.health > 0: body.take_damage(damage)
	elif hitBody != null:
		if (body.currentPlatform != null and hitBody == body.currentPlatform) or (body.is_on_floor() and hitBody.name == "Floor"): #the starting floor needs its own case
			body.launch(position)

func _on_area_entered(area):
	if area.collision_layer == 4: #bullet
		area.queue_free()
