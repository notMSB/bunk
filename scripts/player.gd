extends CharacterBody2D

@onready var UI := get_node("../UI")

const SPEED := 350.0
const JUMP_VELOCITY := -725.0

const PLATFORM_LAYER := 16

const BOTTOM_MOD := 200

#const BOOSTLIMIT = -200
#var jumpBoost = 0

@export var mobile := false
var startingLaunchPos := Vector2(0,0)
var currentLaunchPos := Vector2(0,0)
const MINIMUM_LAUNCH := 30
const MAXIMUM_LAUNCH := 400
const LAUNCH_MULTIPLIER := 3

var launching := false
var crouched := false
var fastfalling := false

var health := 3

var healthWeight := 0
var fuelWeight := 0
var grenadeWeight := 0

const CROUCH_DIFF := 17 #adjusting player position on crouch/uncrouch to prevent going airborne

const BASE_KNOCKBACK = 700 #for when the player takes damage
const BIG_KNOCKBACK = -800 #for when the player is hit by the boss or falls off the bottom

const MAX_FUEL := 100
var fuelThreshold := 5
var fuel := MAX_FUEL

const AIR_JUMPS := 2
var currentAirJumps := 0

var hasItem := true

var jumping := false

const COYOTE_TIME := 5 #frames
var currentCoyote := COYOTE_TIME

const INVULN_TIME := 1.0 #seconds
var currentInvuln := INVULN_TIME
var invulnerable := false

var weaponCooldown := .0 #seconds
var weaponIndex := Global.usedWeapon

var currentPlatform : CharacterBody2D = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Global.shame = Global.easy
	fuelThreshold = 0 if Global.easy else 5

func _physics_process(delta):
	UI.set_height(position.y)
	weaponCooldown = max(weaponCooldown - delta, 0)
	if position.y > $Camera2D.get_screen_center_position().y - $Camera2D.offset.y + BOTTOM_MOD: 
		take_damage(false, 1, true)
		change_fuel(-5 * fuelThreshold)
	if !is_on_floor():
		if crouched and !fastfalling: uncrouch()
		change_velocity(velocity.y + gravity * delta)
		if currentCoyote > 0: currentCoyote -= 1
	else:
		fastfalling = false
		currentCoyote = COYOTE_TIME
		set_platform() #Set a platform which descends when jumping off
		if currentPlatform and velocity.y == 0: change_velocity(currentPlatform.velocity.y)
		currentAirJumps = 0
		UI.set_fuel(fuel, fuelThreshold, currentAirJumps, AIR_JUMPS)
	
	if !mobile: classic_process(delta)
	else: mobile_process()
	
	if invulnerable:
		currentInvuln -= delta
		if currentInvuln <= 0:
			set_invuln(false)
	
	move_and_slide()

func classic_process(delta):
	if launching and velocity.y >= 0: launching = false
	if Input.is_action_just_pressed("swap_up"):
			weaponIndex -= 1
			if weaponIndex < 0: weaponIndex = $Weapon.get_child_count()-1
			weaponCooldown = .1
	if Input.is_action_just_pressed("swap_down"):
		weaponIndex += 1
		if weaponIndex == $Weapon.get_child_count(): weaponIndex = 0
		weaponCooldown = .1
	if Input.is_action_just_pressed("down") and !crouched: crouch()
	if Input.is_action_just_released("down") and crouched: uncrouch()
	
	#Controller support, right stick mouse movement
	var mouseSens := 3000.0
	var mouseDir : Vector2
	var movement : Vector2
	
	mouseDir.x = Input.get_action_strength("rs_right") - Input.get_action_strength("rs_left")
	mouseDir.y = Input.get_action_strength("rs_down") - Input.get_action_strength("rs_up")
	
	if abs(mouseDir.x) == 1 and abs(mouseDir.y) == 1: mouseDir = mouseDir.normalized()
	movement = mouseSens * mouseDir * delta
	if movement: get_viewport().warp_mouse(get_viewport().get_mouse_position() + movement)
	
	var direction = Input.get_axis("ui_left", "ui_right")
	#var speedVal = max(SPEED, abs(velocity.x)-5)
	var speedVal = max(SPEED, abs(velocity.x)-5) if direction * velocity.x > 0 else SPEED
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
	if Input.is_action_just_pressed("misc"): 
		Global.easy = !Global.easy
		Global.shame = true
		fuelThreshold = 0 if Global.easy else 5
	if Input.is_action_just_pressed("item") and hasItem:
		$Item.get_child(0).use()
		change_item(false)
	if Input.is_action_pressed("shoot") and weaponCooldown <= 0:
		fire_weapon()

func mobile_process():
	if is_on_floor():
		velocity.x = 0
		if launching: launching = false
	if Input.is_action_just_pressed("shoot"):
		startingLaunchPos = get_global_mouse_position()
		currentLaunchPos = startingLaunchPos
	elif Input.is_action_pressed("shoot"):
		currentLaunchPos = get_global_mouse_position()
		var direction = (currentLaunchPos - startingLaunchPos).normalized()
		$Line.rotation = direction.angle() - Vector2.DOWN.angle()
		var length = min(startingLaunchPos.distance_to(currentLaunchPos), MAXIMUM_LAUNCH)
		$Line.scale.y = length / 8.0 #length of the sprite used for the line currently
	if Input.is_action_just_released("shoot") and weaponCooldown <= 0:
		fire_weapon()
		
		var force = min(startingLaunchPos.distance_to(currentLaunchPos), MAXIMUM_LAUNCH)
		if force > MINIMUM_LAUNCH: #minimum drag distance for launch
			launching = true
			velocity = $Weapon.get_child(weaponIndex).shot_boost(get_global_mouse_position(), global_position, force * LAUNCH_MULTIPLIER)

func fire_weapon():
	var shot = $Weapon.get_child(weaponIndex).Projectile.instantiate()
	$Projectiles.add_child(shot)
	
	shot.fire(get_global_mouse_position(), global_position, $Weapon.get_child(weaponIndex).DAMAGE, $Weapon.get_child(weaponIndex).get_pierce())
	weaponCooldown = $Weapon.get_child(weaponIndex).COOLDOWN

func set_platform():
	for i in get_slide_collision_count():
		#print(get_slide_collision(i).get_collider().name)
		var col = get_slide_collision(i).get_collider()
		if col != null:
			if col.collision_layer == PLATFORM_LAYER or col.collision_layer == PLATFORM_LAYER * 3:
				if col.get_class() == "CharacterBody2D": #todo: refactor this
					currentPlatform = col
				else: currentPlatform = col.get_parent()
			else:
				currentPlatform = null

func jump():
	if crouched:
		if is_on_floor(): 
			plat_drop()
			return
	else:
		if currentCoyote > 0:
			currentCoyote = 0
			change_velocity(JUMP_VELOCITY)
			if currentPlatform != null: currentPlatform.boost(JUMP_VELOCITY)
			jumping = true
			return
	if fuel >= fuelThreshold and currentAirJumps < AIR_JUMPS:
		currentAirJumps += 1
		change_velocity(JUMP_VELOCITY/1.15)
		velocity.x *= 1.4
		change_fuel(-1 * fuelThreshold)
		jumping = true
		fastfalling = false

func crouch():
	scale.y = .5
	crouched = true
	if !is_on_floor(): 
		velocity.y = max(velocity.y, 600) #fastfall
		fastfalling = true
		position.y -= CROUCH_DIFF
	else: position.y += CROUCH_DIFF

func uncrouch(adjust = true):
	crouched = false
	scale.y = 1
	if adjust: position.y -= CROUCH_DIFF

func change_item(change):
	hasItem = change
	UI.set_item(hasItem)

func change_fuel(change):
	fuel = min(fuel + change, 100)
	UI.set_fuel(fuel, fuelThreshold, currentAirJumps, AIR_JUMPS)

func take_damage(goLeft, _damage = 0, bigHit = false):
	health -= 1
	if health <= 0: die()
	UI.update_health(health, false)
	if bigHit: change_velocity(BIG_KNOCKBACK)
	else: velocity.x = BASE_KNOCKBACK * -1 if goLeft else BASE_KNOCKBACK
	set_invuln(true)

func heal(amount):
	health = min(health + amount, 3)
	UI.update_health(health, true)

func set_invuln(isInvuln):
	if invulnerable and isInvuln: currentInvuln = INVULN_TIME
	else:
		collision_layer -= 1 if isInvuln else -1
		invulnerable = isInvuln

func die():
	var runScore = UI.get_height()
	if runScore > Global.score: Global.score = runScore
	Global.usedWeapon = weaponIndex
	get_tree().call_deferred("reload_current_scene")

func plat_drop():
	position.y += 4
	currentPlatform = null

func launch(boomPos): #from an explosion
	launching = true
	velocity.y = 0
	var direction = (position - boomPos).normalized()
	velocity = 750 * direction
	velocity.x *= 1.5
	if currentPlatform != null: currentPlatform.boost(JUMP_VELOCITY)

func change_velocity(value):
	#if value < -1000:
	#	
	#	print(value)
	velocity.y = value
