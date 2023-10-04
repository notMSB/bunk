extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

const PLATFORM_LAYER = 16

const BOTTOM_MOD = 50

const BOOSTLIMIT = -200
var jumpBoost = 0

var cooldown = 0

var currentPlatform = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if position.y > $Camera2D.get_screen_center_position().y - $Camera2D.offset.y + BOTTOM_MOD:
		get_tree().reload_current_scene()
	if not is_on_floor():
		velocity.y += gravity * delta
		jumpBoost = 0
	if Input.is_action_just_pressed("swap"):
		$Weapon.move_child($Weapon.get_child(0), 1)
		cooldown = $Weapon.get_child(0).COOLDOWN
	if Input.is_action_pressed("down") and is_on_floor():
		jumpBoost -= 2
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	cooldown -= delta
	if Input.is_action_pressed("shoot") and cooldown <= 0:
		var shot = $Weapon.get_child(0).Projectile.instantiate()
		get_node("../Projectiles").add_child(shot)
		
		shot.fire(get_global_mouse_position(), global_position)
		cooldown = $Weapon.get_child(0).COOLDOWN
	
	#Set a platform which descends when jumping off
	if !is_on_floor(): currentPlatform = null
	else:
		for i in get_slide_collision_count():
		#print(get_slide_collision(i).get_collider().name)
			var col = get_slide_collision(i).get_collider()
			if col == null: currentPlatform = null
			elif col.collision_layer == PLATFORM_LAYER:
				currentPlatform = col.get_parent()
	
	
	move_and_slide()

func jump():
	velocity.y = JUMP_VELOCITY + max(jumpBoost, BOOSTLIMIT)
	if currentPlatform: currentPlatform.boost(JUMP_VELOCITY + max(jumpBoost, BOOSTLIMIT))
	currentPlatform = null
