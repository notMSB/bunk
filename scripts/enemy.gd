extends CharacterBody2D

const DEFAULT_VELOCITY = 50

var camera

var isPlatform = false

var killTimerSet = false
var killTimer = 1

const BOOST_MOD = .5
const BOOST_DEFAULT = .2
var boostTimerSet = false
var boostTimer = BOOST_DEFAULT

@export var health = 3

func _ready():
	velocity.y = DEFAULT_VELOCITY
	$UI/HPText.text = str(health)

func _physics_process(delta):
	move_and_slide()
	if camera and position.y > camera.get_screen_center_position().y + 375 and velocity.y >= 0:
		if isPlatform and velocity.y <= DEFAULT_VELOCITY: velocity.y = 0
		killTimerSet = true
		#queue_free()
	if killTimerSet: killTimer -= delta
	if killTimer <= 0: queue_free()
	if boostTimerSet: boostTimer -= delta
	if boostTimer <= 0:
		boostTimerSet = false
		boostTimer = BOOST_DEFAULT
		velocity.y = DEFAULT_VELOCITY

func setup(p, cam):
	camera = cam
	$AI.setup(p)

func change():
	velocity.x = 0
	velocity.y = DEFAULT_VELOCITY
	isPlatform = true
	$UI/HPText.visible = false
	$AI.queue_free()
	var spriteCount = $Sprites.get_child_count()
	for sprite in $Sprites.get_children():
		sprite.texture = ResourceLoader.load("res://assets/sprites/platform.png")
		if sprite.get_index() == 1: #temp
			sprite.rotation = 0
			sprite.position.y = 0
			if spriteCount == 2: sprite.position.x = -32
			else: sprite.position.x = 32
		elif sprite.get_index() > 1:
			sprite.visible = false
	
	$PlatformBody.visible = true
	$ContactDamage.visible = false
	if get_node_or_null("AltShape"): #change collision if platform layout is different
		$EnemyShape.set_deferred("disabled", true)
		$AltShape.visible = true
	set_collision_layer_value(6, 1)
	set_collision_layer_value(2, 0)
	set_collision_mask_value(1, 0)

func boost(value):
	boostTimerSet = true
	velocity.y -= BOOST_MOD * value

func unboost():
	boostTimerSet = false
	velocity.y = DEFAULT_VELOCITY

func take_damage(amount):
	if Global.oneshot: change()
	else:
		health -= amount
		if health <= 0: change()
		else: $UI/HPText.text = str(health)

func _on_contact_damage_body_entered(body):
	if $ContactDamage.visible and body.collision_layer == 1: #damage player
		body.die()

