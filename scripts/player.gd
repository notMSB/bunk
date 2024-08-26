extends CharacterBody2D

@onready var UI := get_node("../UI")

# Movement
#const SPEED := 350.0
const move_speed_decel_floor 	:= 60.0
const move_speed_decel_air 		:= 60.0
const move_speed_accel 			:= 30.0	## How fast they speed up to max speed
const move_speed_decel_manual 	:= 90.0	## Manual deceleration speed, such as moving in the opposite direction of the current velocity
const move_speed_decel_maxed_manual 	:= 30.0	## Manual deceleration speed when above max
const move_speed_decel_maxed 	:= 5.0		## Player's deceleration speed when they are beyond their max speed
const move_speed_max 			:= 600.0
var move_speed_current := 0.0

# Jumps
var jumping := false
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_decel 				= 2250.0 # Decel gravity allows floating more
var gravity_accel 				= 2500.0 # Accel gravity brings player down
const GRAVITY_MAX				= 1400.0
const JUMP_VELOCITY 			:= -1000 #-1065.0 #-725.0
const AIR_JUMP_VELOCITY 		:= JUMP_VELOCITY / 1.15
const JUMP_TIME					:= 5.0/60.0 # fractions of a second. For setting full velocity of jump for a time, to make it smoother
const AIR_JUMP_TIME				:= 5.0/60.0 # fractions of a second. For setting full velocity of jump for a time, to make it smoother
var JUMP_SHORT_GRAVITY			= gravity_accel * 1.7 # + 1400.0	# Speed of gravity when short jumping
var JUMP_SHORT_DECEL			= gravity_accel * 2 # 2000.0	# Deceleration when short jumping, so the jump ends sooner
var jump_alarm = 0
const AIR_JUMPS 				:= 2
var currentAirJumps := 0
const COYOTE_TIME 				:= 5 #frames
var currentCoyote := COYOTE_TIME
#var gravity 					= ProjectSettings.get_setting("physics/2d/default_gravity")
var fastfalling := false
var short_jumping = false
const CROUCH_FASTFALL_SPEED 			:= 600.0


const PLATFORM_LAYER := 16

const BOTTOM_MOD := 125

#const BOOSTLIMIT = -200
#var jumpBoost = 0

var mobile : bool = Global.useMobile
var startingLaunchPos := Vector2(0,0)
var currentLaunchPos := Vector2(0,0)
const MINIMUM_LAUNCH := 20
const MAXIMUM_LAUNCH := 250
const LAUNCH_MULTIPLIER := 3
var fuelTick := false

var launching := false
var crouched := false

var health := 3

var healthWeight := 0
var fuelWeight := 0
var grenadeWeight := 0

const CROUCH_DIFF := 17 #adjusting player position on crouch/uncrouch to prevent going airborne

const BASE_KNOCKBACK_X 	= 700 #for when the player takes damage
const BASE_KNOCKBACK_Y 	= 1150 #700 #for when the player takes damage
const BIG_KNOCKBACK_X 	= 800 #for when the player is hit by the boss or falls off the bottom
const BIG_KNOCKBACK_Y 	= -1300 #800 #for when the player is hit by the boss or falls off the bottom

const MAX_FUEL := 100
var fuelThreshold := 5
var fuel := MAX_FUEL


var hasItem := true

const INVULN_TIME := 1.0 #seconds
var currentInvuln := INVULN_TIME
var invulnerable := false

var weaponCooldown := .0 #seconds
var weaponIndex := Global.usedWeapon

var currentPlatform : CharacterBody2D = null


func _ready():
	if mobile: $Camera2D.zoom = Vector2(1,1)
	Global.shame = Global.easy
	fuelThreshold = 0 if Global.easy else 5

func _physics_process(delta):
	
	UI.set_height(position.y)
	weaponCooldown = max(weaponCooldown - delta, 0)
	
	# Player is off screen
	if position.y > $Camera2D.get_screen_center_position().y - (($Camera2D.offset.y - BOTTOM_MOD) / $Camera2D.zoom.y): 
		take_damage(false, 1, true)
		change_fuel(-5 * fuelThreshold)
	
	# Apply gravity
	if !is_on_floor():
		if crouched and !fastfalling: 
			uncrouch()
		
		
		if jump_alarm == 0:
			
			# Apply decel to slow down when starting to fall
			if(velocity.y < 0):
				
				# When short jumping, increase gravity to end the jump sooner
				var _selected_gravity
				if short_jumping:
					_selected_gravity = JUMP_SHORT_DECEL
					pass
				else:
					_selected_gravity = gravity_decel
					pass
				
				change_velocity(min(0, velocity.y + _selected_gravity * delta))
				
				pass
			# Apply gravity fully when falling
			else:
				
				# When short jumping, increase gravity to end the jump sooner
				var _selected_gravity
				if short_jumping:
					_selected_gravity = JUMP_SHORT_GRAVITY
					pass
				else:
					_selected_gravity = gravity_accel
					pass
				
				
				change_velocity(min(GRAVITY_MAX, velocity.y + _selected_gravity * delta))
				pass
			
			
		
		
		if currentCoyote > 0: 
			currentCoyote -= 1
		
	# On floor / landed
	else:
		fastfalling = false
		currentCoyote = COYOTE_TIME
		set_platform() #Set a platform which descends when jumping off
		if is_instance_valid(currentPlatform):
			if velocity.y == 0: change_velocity(currentPlatform.velocity.y)
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
	
	# Weapon swapping
	if Input.is_action_just_pressed("swap_up"):
			weaponIndex -= 1
			if weaponIndex < 0: weaponIndex = $Weapon.get_child_count()-1
			weaponCooldown = .1
	if Input.is_action_just_pressed("swap_down"):
		weaponIndex += 1
		if weaponIndex == $Weapon.get_child_count(): weaponIndex = 0
		weaponCooldown = .1
	
	# Crouching
	if Input.is_action_just_pressed("down") and !crouched: crouch()
	if Input.is_action_just_released("down") and crouched: uncrouch()
	
	# Moving
	move_player_horizontal(delta)
	
	
	# Jumping / Double jump
	if jump_alarm > 0:
		jump_alarm = max(0, jump_alarm - delta)
		
		#if(jump_alarm == 0):
			#
			#pass
	
	if Input.is_action_just_pressed("jump"): 
		jump()
	
	# short jumping
	if Input.is_action_just_released("jump") and velocity.y < 0 and jumping: 
		#change_velocity(velocity.y * 0.4)
		jumping = false
		short_jumping = true
		jump_alarm = 0
		if currentPlatform != null: 
			currentPlatform.unboost()
			currentPlatform = null
	
	# Easy mode swap
	if Input.is_action_just_pressed("misc"): 
		Global.easy = !Global.easy
		Global.shame = true
		fuelThreshold = 0 if Global.easy else 5
	
	# Use items
	if Input.is_action_just_pressed("item") and hasItem:
		$Item.get_child(0).use()
		change_item(false)
	
	
	
	# Shooting
	if Input.is_action_pressed("shoot") and weaponCooldown <= 0:
		fire_weapon()

func mobile_process():
	if fuelTick == false: fuelTick = true
	elif fuel > 100: 
		change_fuel(-1)
		fuelTick = false
	elif fuel < 100 and is_on_floor():
		change_fuel(1)
		fuelTick = false
	if is_on_floor():
		velocity.x = 0
		if launching: launching = false
	
	# Get angle to fire
	if Input.is_action_just_pressed("shoot"):
		startingLaunchPos = get_global_mouse_position()
		currentLaunchPos = startingLaunchPos
	elif Input.is_action_pressed("shoot"):
		currentLaunchPos = get_global_mouse_position()
		var direction = (currentLaunchPos - startingLaunchPos).normalized()
		$Line.visible = true
		$Line.rotation = direction.angle() - Vector2.DOWN.angle()
		var length = min(startingLaunchPos.distance_to(currentLaunchPos), MAXIMUM_LAUNCH)
		$Line.scale.y = length / 8.0 #length of the sprite used for the line currently
	
	# Fire weapon
	if Input.is_action_just_released("shoot"): 
		$Line.visible = false
		if weaponCooldown <= 0:
			fire_weapon()
			var force = min(startingLaunchPos.distance_to(currentLaunchPos), MAXIMUM_LAUNCH)
			if fuel * 10 < force: 
				force = fuel * 10
				if force == 0: velocity.x = 0
			if force > MINIMUM_LAUNCH: #minimum drag distance for launch
				change_fuel(ceil(-1 * force / 10))
				launching = true
				velocity = $Weapon.get_child(weaponIndex).shot_boost(currentLaunchPos, startingLaunchPos, force * LAUNCH_MULTIPLIER)

func move_player_horizontal(delta):
	
	# Moves player left/right based on controls
	
	var mouseSens := 3000.0
	var mouseDir : Vector2
	var movement : Vector2
	
	# Get Input
	#Controller support, right stick mouse movement
	mouseDir.x = Input.get_action_strength("rs_right") - Input.get_action_strength("rs_left")
	mouseDir.y = Input.get_action_strength("rs_down") - Input.get_action_strength("rs_up")
	
	# No need to check if it's 1... As that will only allow when it's absolutely 1/-1, and not any less. 
	# Probably won't work for controllers in this case. You can just normalize it without checking
	if abs(mouseDir.x) == 1 and abs(mouseDir.y) == 1: 
		mouseDir = mouseDir.normalized()
	
	# Apply mouse movement
	movement = mouseSens * mouseDir * delta
	
	# ?
	if movement: 
		get_viewport().warp_mouse(get_viewport().get_mouse_position() + movement)
	
	# Get keyboard input
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Get Speed
	#var speedVal = max(SPEED, abs(velocity.x)-5)
	# ???
	#var speedVal = max(SPEED, abs(velocity.x)-5) if direction * velocity.x > 0 else SPEED
	
	
	# Speed player up, capping to speed max
	# Uses velocity, so it can be affected by outside sources easily and account for it
	move_speed_current = velocity.x
	if direction != 0 && !fastfalling:
		
		# Decelerate player if they change directions while moving
		# Otherwise speed them up normally
		var _move_speed_accel_now
		var _move_same_direction = true
		if move_speed_current < 0 && direction > 0 || move_speed_current > 0 && direction < 0:
			_move_speed_accel_now = move_speed_decel_manual * sign(direction)
			_move_same_direction = false
		else:
			_move_speed_accel_now = move_speed_accel * sign(direction)
		
		# If we're going above max speed (like being knocked back while moving), slow down to our max speed
		if abs(move_speed_current) > move_speed_max:
			# Moving same direction, so slow us down
			if _move_same_direction:
				move_speed_current = move_toward(move_speed_current, move_speed_max * sign(move_speed_current), move_speed_decel_maxed)
				pass
			# Moving opposite direction, use manual decel
			else:
				move_speed_current = move_toward(move_speed_current, move_speed_max * sign(move_speed_current), move_speed_decel_maxed_manual)
				pass
		# Speed up to max speed normally
		else:
			move_speed_current = clamp(move_speed_current + _move_speed_accel_now, -move_speed_max, move_speed_max)
		
	# Slow player down when not moving
	elif abs(move_speed_current) > 0:
		
		if is_on_floor():
			move_speed_current = move_toward(move_speed_current, 0, move_speed_decel_floor)
		else:
			move_speed_current = move_toward(move_speed_current, 0, move_speed_decel_air)
		
	
	
	
	# Set velocity
	velocity.x = move_speed_current
	
	
	## Speed player up
	#if direction:
		#velocity.x = direction * speedVal
	## Slow player down
	#else:
		#if is_on_floor():
			#velocity.x = move_toward(velocity.x, 0, move_speed_decel_floor)
		#else:
			#velocity.x = move_toward(velocity.x, 0, move_speed_decel_air)
	

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
	# ??? Crouch jump?
	if crouched:
		if is_on_floor(): 
			plat_drop()
			return
	# Jump
	else:
		if currentCoyote > 0:
			currentCoyote = 0
			
			# Set speed
			change_velocity(JUMP_VELOCITY)
			jump_alarm = JUMP_TIME
			
			# ???
			if currentPlatform != null: currentPlatform.boost(JUMP_VELOCITY)
			jumping = true
			short_jumping = false
			return
	
	# air jumps
	if fuel >= fuelThreshold and currentAirJumps < AIR_JUMPS:
		currentAirJumps += 1
		
		# Set Speed
		change_velocity(AIR_JUMP_VELOCITY)
		jump_alarm = AIR_JUMP_TIME
		
		# Slow player down horizontally
		velocity.x *= 1.4
		
		change_fuel(-1 * fuelThreshold)
		jumping = true
		short_jumping = false
		fastfalling = false

func crouch():
	scale.y = .5
	crouched = true
	
	# Fast fall when in air
	if !is_on_floor(): 
		fastfalling = true
		jump_alarm = 0
		#velocity.x = 0 # Remove horizontal velocity so it acts like an anchor
		velocity.y = max(velocity.y, CROUCH_FASTFALL_SPEED)
		position.y -= CROUCH_DIFF
	else: 
		position.y += CROUCH_DIFF

func uncrouch(adjust = true):
	crouched = false
	fastfalling = false
	scale.y = 1
	if adjust: position.y -= CROUCH_DIFF

func change_item(change):
	hasItem = change
	UI.set_item(hasItem)

func change_fuel(change):
	if mobile: fuel = max(fuel + change, 0)
	else: fuel = clamp(fuel + change, 0, 100)
	UI.set_fuel(fuel, fuelThreshold, currentAirJumps, AIR_JUMPS)

func take_damage(goLeft, _damage = 0, bigHit = false):
	health -= 1
	if health <= 0: die()
	UI.update_health(health, false)
	if bigHit: change_velocity(BIG_KNOCKBACK_Y)
	else: velocity.x = -BASE_KNOCKBACK_X if goLeft else BASE_KNOCKBACK_X
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
	jump_alarm = 0
	var direction = (position - boomPos).normalized()
	velocity = 750 * direction
	velocity.x *= 1.5
	if currentPlatform != null: currentPlatform.boost(JUMP_VELOCITY)

func change_velocity(value):
	#if value < -1000:
	#	
	#	print(value)
	velocity.y = value
