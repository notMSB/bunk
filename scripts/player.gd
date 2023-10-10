extends CharacterBody2D

@onready var UI = get_node("../UI")

var scoreModifier = 600

const SPEED = 300.0
const JUMP_VELOCITY = -625.0

const PLATFORM_LAYER = 16

const BOTTOM_MOD = 150

#const BOOSTLIMIT = -200
#var jumpBoost = 0

const MAX_FUEL = 100
const FUEL_THRESHOLD = 50
var fuel = MAX_FUEL

const COYOTE_TIME = 5
var currentCoyote = COYOTE_TIME

var weaponCooldown = 0

var currentPlatform = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	UI.set_height(scoreModifier, position.y)
	weaponCooldown = max(weaponCooldown - delta, 0)
	if position.y > $Camera2D.get_screen_center_position().y - $Camera2D.offset.y + BOTTOM_MOD:
		var runScore = UI.get_height()
		if runScore > Global.score: Global.score = runScore
		get_tree().reload_current_scene()
	if !is_on_floor():
		velocity.y += gravity * delta
		if currentCoyote > 0: currentCoyote -= 1
	else:
		currentCoyote = COYOTE_TIME
		set_platform() #Set a platform which descends when jumping off
		if fuel < MAX_FUEL:
			fuel += 1
			UI.set_fuel(fuel)
	
	if Input.is_action_just_pressed("swap"):
		$Weapon.move_child($Weapon.get_child(0), 1)
		weaponCooldown = $Weapon.get_child(0).COOLDOWN
	if Input.is_action_just_pressed("down") and is_on_floor(): plat_drop()
	#if Input.is_action_pressed("down") and is_on_floor():
	#	jumpBoost -= 2
	var direction = Input.get_axis("ui_left", "ui_right")
	var speedVal = max(SPEED, abs(velocity.x)-5)
	if direction:
		velocity.x = direction * speedVal
	else:
		velocity.x = move_toward(velocity.x, 0, speedVal)
	if Input.is_action_just_pressed("jump"): jump()
	if Input.is_action_just_released("jump") and velocity.y < 0: 
		velocity.y = 0
		if currentPlatform: 
			currentPlatform.unboost()
			currentPlatform = null
	if Input.is_action_pressed("shoot") and weaponCooldown <= 0:
		var shot = $Weapon.get_child(0).Projectile.instantiate()
		$Projectiles.add_child(shot)
		
		shot.fire(get_global_mouse_position(), global_position)
		weaponCooldown = $Weapon.get_child(0).COOLDOWN
	
	move_and_slide()

func set_platform():
	for i in get_slide_collision_count():
		#print(get_slide_collision(i).get_collider().name)
		var col = get_slide_collision(i).get_collider()
		if col.collision_layer == PLATFORM_LAYER:
			currentPlatform = col.get_parent()

func jump():
	if currentCoyote > 0:
		currentCoyote = 0
		velocity.y = JUMP_VELOCITY
		if currentPlatform: currentPlatform.boost(JUMP_VELOCITY)
	elif fuel >= FUEL_THRESHOLD:
		velocity.y = JUMP_VELOCITY/2
		velocity.x *= 2
		fuel -= FUEL_THRESHOLD
		UI.set_fuel(fuel)

func plat_drop():
	position.y += 4
