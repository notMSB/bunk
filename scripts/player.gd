extends CharacterBody2D

@export var Bullet : PackedScene

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const BOOSTLIMIT = -200
var jumpBoost = 0

const BOTTOM_MOD = 50

const SHOT_COOLDOWN = .1
var cooldown = SHOT_COOLDOWN

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var bottomLimit = $Camera2D.get_screen_center_position().y - $Camera2D.offset.y + BOTTOM_MOD
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		jumpBoost -= 2
	if Input.is_action_just_released("ui_accept") and is_on_floor() or position.y > bottomLimit:
		jump()
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	cooldown -= delta
	if Input.is_action_pressed("shoot") and cooldown <= 0:
		var shot = Bullet.instantiate()
		get_node("../Projectiles").add_child(shot)
		
		shot.fire(get_global_mouse_position(), global_position)
		cooldown = SHOT_COOLDOWN
	
	move_and_slide()

func jump():
	velocity.y = JUMP_VELOCITY + max(jumpBoost, BOOSTLIMIT)
	jumpBoost = 0
