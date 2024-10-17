extends CharacterBody2D

const DEFAULT_VELOCITY := 60

@onready var player : CharacterBody2D = Global.player
var camera : Camera2D

var isPlatform := false

const DEFAULT_KILL_TIMER := 1.0
var killTimerSet := false
var killTimer := .0

const BOOST_MOD := .5
const BOOST_DEFAULT := .2
var boostTimerSet := false
var boostTimer := BOOST_DEFAULT

@export var health := 4
@export var damage := 1
@export var pickup_spawn_chance := 1.0
@export var platform_only := false

func _ready():
	velocity.y = DEFAULT_VELOCITY * 2
	$UI/HPText.text = str(health)
	
	# Cheap hack. Keep existing behaviour of enemy platforms, but just spawn this as a platform, not an enemy. 
	if(platform_only):
		health = 0
		change()
		pass

func _physics_process(delta):
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
	$ContactDamage.visible = false
	set_collision_layer_value(6, 1)
	set_collision_layer_value(2, 0)
	set_collision_mask_value(1, 0)
	$ContactDamage.visible = false
	if Global.useMobile: scale.x *= 2
	
	if get_node_or_null("Platforms"): multi_platform()
	else: single_platform()

func single_platform():
	$PlatformBody.visible = true
	$PlatformBody/PlatformShape.set_deferred("disabled", false)
	var spriteCount := $Sprites.get_child_count()
	for sprite in $Sprites.get_children():
		sprite.texture = ResourceLoader.load("res://assets/sprites/platform.png")
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
	if !platform_only && randf() <= pickup_spawn_chance:
		
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
	if !platform_only && randf() <= pickup_spawn_chance:
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
	if $ContactDamage.visible and body.collision_layer == 65: #damage player
		var knockbackDir := false if body.position.x > position.x else true
		if body.launching: take_damage(health) #a boosting player damages enemies
		else: body.take_damage(knockbackDir, damage)
