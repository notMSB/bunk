extends CharacterBody2D

const DEFAULT_VELOCITY := 50

var camera : Camera2D

var killTimerSet := false
var killTimer := 1.0

const BOOST_MOD := .5
const BOOST_DEFAULT := .2
var boostTimerSet := false
var boostTimer := BOOST_DEFAULT

func _physics_process(delta):
	move_and_slide()
	if camera and global_position.y > camera.get_screen_center_position().y + 375 / camera.zoom.y and velocity.y >= 0:
		if velocity.y <= DEFAULT_VELOCITY: velocity.y = 0
		killTimerSet = true
		#queue_free()
	if killTimerSet: killTimer -= delta
	if killTimer <= 0: queue_free()
	if boostTimerSet: boostTimer -= delta
	if boostTimer <= 0:
		boostTimerSet = false
		boostTimer = BOOST_DEFAULT
		velocity.y = DEFAULT_VELOCITY

func setup(cam, player = null):
	camera = cam
	velocity.y = DEFAULT_VELOCITY
	if player != null:
		get_node("Pickup").setup(player, get_node("Pickup").SPAWN_SOURCE.Platform)

func boost(value):
	boostTimerSet = true
	velocity.y -= BOOST_MOD * value

func unboost():
	boostTimerSet = false
	velocity.y = DEFAULT_VELOCITY
