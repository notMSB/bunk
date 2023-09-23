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

func _ready():
	velocity.y = DEFAULT_VELOCITY

func _physics_process(delta):
	move_and_slide()
	if camera and position.y > (camera.get_screen_center_position().y + 320):
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

func set_camera(cam):
	camera = cam

func change():
	velocity.x = 0
	isPlatform = true
	$Sprite2D.texture = ResourceLoader.load("res://assets/sprites/platform.png")
	$PlatformBody.visible = true
	$ContactDamage.visible = false
	set_collision_layer_value(6, 1)
	set_collision_layer_value(2, 0)
	set_collision_mask_value(1, 0)

func boost(value):
	boostTimerSet = true
	velocity.y -= BOOST_MOD * value

func _on_contact_damage_body_entered(body):
	if $ContactDamage.visible and body.collision_layer == 1: #damage player
		get_tree().reload_current_scene()
