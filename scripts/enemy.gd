extends CharacterBody2D

const DEFAULT_VELOCITY := 60

@onready var player : CharacterBody2D = Global.player
@onready var AI = $AI
var camera : Camera2D

var isPlatform := false
@export var blocks_projectiles = false
@export var platform_only := false
@export var platform_sprite = "res://assets/sprites/platform.png"

const DEFAULT_KILL_TIMER := 1.0
var killTimerSet := false
var killTimer := .0

const BOOST_MOD := .5
const BOOST_DEFAULT := .2
var boostTimerSet := false
var boostTimer := BOOST_DEFAULT

@export var health := 4
@export var damage := 1
@export var pickup_spawn_chance = [
		# array of spawn chances for pickups. Can be overwritten per enemy. 
		# first element: max elevation for chance
		# second element: drop chance from 0-1
		[1000, 0.10] # 0.10
	,	[2500, 0.092]
	,	[4000, 0.083]
	,	[6500, 0.075]
]


var time_speed := 1.0


func _ready():
	velocity.y = DEFAULT_VELOCITY * 2
	$UI/HPText.text = str(health)
	
	# Cheap hack. Keep existing behaviour of enemy platforms, but just spawn this as a platform, not an enemy. 
	if(platform_only):
		health = 0
		change()
		pass
	
	Global.player.get_node("Item/grenade").time_freeze.connect(time_freeze) 
	if Global.player.get_node("Item/grenade").time_freeze_active: time_freeze(Global.player.get_node("Item/grenade").time_speed)
	

func _physics_process(delta):
	
	delta *= time_speed
	if delta == 0: return
	
	move_and_slide()
	if killTimerSet: 
		killTimer -= delta
		if killTimer <= 0:
			queue_free()
	elif camera and position.y > camera.get_screen_center_position().y + 375 / camera.zoom.y and velocity.y >= 0:
		if isPlatform and velocity.y <= DEFAULT_VELOCITY: 
			velocity.y = 0
			killTimer = DEFAULT_KILL_TIMER
		killTimerSet = true
		#queue_free()
	if boostTimerSet: boostTimer -= delta
	if boostTimer <= 0:
		boostTimerSet = false
		boostTimer = BOOST_DEFAULT
		velocity.y = DEFAULT_VELOCITY
	
	#for body in $PlatformBody.get_overlapping_bodies():
		#print("Enemy overlapping bodies - body name:" + body.name + ". body parent name: " + body.get_parent().name)

func setup(cam, p):
	camera = cam
	#player = p
	$AI.setup(p)

func change():
	velocity.x = 0
	velocity.y = DEFAULT_VELOCITY
	isPlatform = true
	$UI/HPText.visible = false
	$AI.queue_free()
	set_collision_layer_value(6, 1)
	set_collision_layer_value(2, 0)
	set_collision_mask_value(1, 0)
	if Global.useMobile: scale.x *= 2
	
	# Keep area to use for bullet collisions
	if isPlatform && blocks_projectiles:
		#$ContactDamage.visible = false
		pass
	else:
		$ContactDamage.visible = false
		pass
	
	if get_node_or_null("Platforms"): multi_platform()
	else: single_platform()

func single_platform():
	$PlatformBody.visible = true
	$PlatformBody/PlatformShape.set_deferred("disabled", false)
	var spriteCount := $Sprites.get_child_count()
	for sprite in $Sprites.get_children():
		sprite.texture = ResourceLoader.load(platform_sprite)
		if sprite.get_index() == 1: #temp
			sprite.rotation = 0
			sprite.position.y = 0
			if spriteCount == 2: sprite.position.x = -32
			else: sprite.position.x = 32
		elif sprite.get_index() > 1:
			sprite.visible = false
	
	if get_node_or_null("AltShape"): #change collision if platform layout is different
		$EnemyShape.set_deferred("disabled", true)
		$AltShape.visible = true
	
	# Chance to spawn pickups
	var _pickup_chance = 0
	for i in pickup_spawn_chance.size():
		if Global.UI.get_height() < pickup_spawn_chance[i][0]:
			_pickup_chance = pickup_spawn_chance[i][1]
			break;
	
	if !platform_only && randf() <= _pickup_chance:
		
		# Spawn pickup
		var _pickup_instance = load("res://scenes/pickup.tscn").instantiate()
		add_child(_pickup_instance)
		
		# Position above platform
		_pickup_instance.position = $PlatformBody.position
		_pickup_instance.position.y -= 42
		_pickup_instance.setup(player, _pickup_instance.SPAWN_SOURCE.Enemy)
		
		pass

func multi_platform():
	$Platforms.visible = true
	velocity.y = 0
	for platform in $Platforms.get_children():
		platform.get_node("Shape").set_deferred("disabled", false)
		platform.velocity.y = platform.DEFAULT_VELOCITY
		platform.setup(camera)
	$Sprites.visible = false
	$EnemyShape.set_deferred("disabled", true)
	#$Platforms.visible = true
	
	# Chance to spawn pickups
	var _pickup_chance = 0
	for i in pickup_spawn_chance.size():
		if Global.UI.get_height() < pickup_spawn_chance[i][0]:
			_pickup_chance = pickup_spawn_chance[i][1]
			break;
	
	# Chance to spawn pickups
	if !platform_only && randf() <= _pickup_chance:
		var chosen_platform = $Platforms.get_child(randi_range(0, $Platforms.get_child_count()-1))
		
		# Spawn pickup
		var _pickup_instance = load("res://scenes/pickup.tscn").instantiate()
		chosen_platform.add_child(_pickup_instance)
		
		# Position above platform
		_pickup_instance.position.x = 0
		_pickup_instance.position.y -= 42
		_pickup_instance.setup(player, _pickup_instance.SPAWN_SOURCE.Enemy)
		
		pass
	

func boost(value):
	boostTimerSet = true
	velocity.y -= BOOST_MOD * value

func unboost():
	boostTimerSet = false
	velocity.y = DEFAULT_VELOCITY

func take_damage(amount):
	health -= amount
	if health <= 0: change()
	else: $UI/HPText.text = str(health)
	
	# Call AI function
	if $AI.has_method("on_enemy_damaged"):	$AI.on_enemy_damaged()
	

func _on_contact_damage_body_entered(body):
	print("Enemy _on_contact_damage_body_entered - body name: " + body.name + ". body parent name: " + body.get_parent().name)
	# Block projectiles when entering body and am a platform
	if !isPlatform && $ContactDamage.visible and body.collision_layer == 65: #damage player
		var knockbackDir := false if body.position.x > position.x else true
		if body.launching: take_damage(health) #a boosting player damages enemies
		else: body.take_damage(knockbackDir, damage)
	

func time_freeze(_time_speed):
	time_speed = _time_speed
	
	if $AI != null:
		AI.time_speed = _time_speed
	else:
		print("time_freeze: Enemy does not have AI: " + self.name)
	pass

func _on_contact_damage_area_entered(area):
	# Clear projectiles colliding with object
	print("Enemy _on_contact_damage_body_entered - area name: " + area.name + ". area parent name: " + area.get_parent().name)
	if isPlatform && blocks_projectiles && area.get_parent().name == "Projectiles":
		area.queue_free()
		#body.call_deferred("queue_free")
		pass
	pass # Replace with function body.
