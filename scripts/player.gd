extends CharacterBody2D

@onready var UI = get_node("../UI")

var scoreModifier = 600

const SPEED = 300.0
const JUMP_VELOCITY = -625.0

const PLATFORM_LAYER = 16

const BOTTOM_MOD = 150

#const BOOSTLIMIT = -200
#var jumpBoost = 0

var health = 1

const MAX_FUEL = 100
const FUEL_THRESHOLD = 50
var fuel = MAX_FUEL

var jumping = false

const COYOTE_TIME = 5
var currentCoyote = COYOTE_TIME

var weaponCooldown = 0
var weaponIndex = 0

var currentPlatform = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	UI.set_height(scoreModifier, position.y)
	weaponCooldown = max(weaponCooldown - delta, 0)
	if position.y > $Camera2D.get_screen_center_position().y - $Camera2D.offset.y + BOTTOM_MOD: die()
	if !is_on_floor():
		change_velocity(velocity.y + gravity * delta)
		if currentCoyote > 0: currentCoyote -= 1
	else:
		currentCoyote = COYOTE_TIME
		set_platform() #Set a platform which descends when jumping off
		if fuel < MAX_FUEL:
			fuel += 1
			UI.set_fuel(fuel)
	if Input.is_action_just_pressed("swap_up"):
		weaponIndex -= 1
		if weaponIndex < 0: weaponIndex = $Weapon.get_child_count()-1
		weaponCooldown = .1
	if Input.is_action_just_pressed("swap_down"):
		weaponIndex += 1
		if weaponIndex == $Weapon.get_child_count(): weaponIndex = 0
		weaponCooldown = .1
	if Input.is_action_just_pressed("down") and is_on_floor(): plat_drop()
	#if Input.is_action_pressed("down") and is_on_floor():
	#	jumpBoost -= 2
	var direction = Input.get_axis("ui_left", "ui_right")
	var speedVal = max(SPEED, abs(velocity.x)-5)
	if direction:
		velocity.x = direction * speedVal
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, 30)
	if Input.is_action_just_pressed("jump"): jump()
	if Input.is_action_just_released("jump") and velocity.y < 0 and jumping: 
		change_velocity(velocity.y * 0.4)
		jumping = false
		if currentPlatform != null: 
			currentPlatform.unboost()
			currentPlatform = null
	if Input.is_action_pressed("shoot") and weaponCooldown <= 0:
		var shot = $Weapon.get_child(weaponIndex).Projectile.instantiate()
		$Projectiles.add_child(shot)
		
		shot.fire(get_global_mouse_position(), global_position, $Weapon.get_child(weaponIndex).DAMAGE)
		weaponCooldown = $Weapon.get_child(weaponIndex).COOLDOWN
	if Input.is_action_just_pressed("misc"): Global.oneshot = !Global.oneshot
	move_and_slide()

func set_platform():
	for i in get_slide_collision_count():
		#print(get_slide_collision(i).get_collider().name)
		var col = get_slide_collision(i).get_collider()
		if col != null:
			currentPlatform = col.get_parent() if col.collision_layer == PLATFORM_LAYER else null

func jump():
	if currentCoyote > 0:
		currentCoyote = 0
		change_velocity(JUMP_VELOCITY)
		if currentPlatform != null: currentPlatform.boost(JUMP_VELOCITY)
		jumping = true
	elif fuel >= FUEL_THRESHOLD:
		change_velocity(JUMP_VELOCITY/2)
		velocity.x *= 2
		fuel -= FUEL_THRESHOLD
		UI.set_fuel(fuel)
		jumping = true

func take_damage(_damage):
	die()

func die():
	var runScore = UI.get_height()
	if runScore > Global.score: Global.score = runScore
	get_tree().reload_current_scene()

func plat_drop():
	position.y += 4
	currentPlatform = null

func launch(boomPos): #from an explosion
	var direction = (position - boomPos).normalized()
	velocity = 750 * direction
	velocity.x *= 1.5
	currentPlatform = null

func change_velocity(value):
	#if value < -1000:
	#	
	#	print(value)
	velocity.y = value
