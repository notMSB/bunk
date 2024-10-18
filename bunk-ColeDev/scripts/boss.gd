extends "res://scripts/enemy.gd"

@onready var bar := get_node("../../UI/BossBar")
@onready var barText := get_node("../../UI/BossBar/Text")
#var playerY : float

const THRESHOLD := 50
var nextCheck : int

var spawnOffset : float = 400

const BASE_SPEED := .3
const SPEED_RAMP := .001
const MAX_SPEED := 1.6
var speed := BASE_SPEED


var weapon_pickup = null

func _ready():
	nextCheck = health - THRESHOLD
	bar.max_value = health
	bar.value = health
	barText.text = str(health)
	bar.visible = true

func _physics_process(_delta):
	recalibrate()
	if isPlatform: position.y += BASE_SPEED
	else:
		var basePos = camera.get_screen_center_position().y + spawnOffset
		if position.y > basePos: position.y = basePos
		if health <= nextCheck: 
			position.y = basePos
			nextCheck -= THRESHOLD
			speed = BASE_SPEED
		else: 
			position.y -= speed
			if speed < MAX_SPEED: speed += SPEED_RAMP

func setup(cam, p):
	camera = cam
	player = p
	
	position.y = camera.get_screen_center_position().y + spawnOffset
	
	recalibrate()

func take_damage(amount):
	health -= amount
	if health <= 0: 
		change()
		bar.visible = false
		get_node("../../UI").unpause(player.position.y)
		
		# Spawn weapon pickup
		weapon_pickup = load("res://scenes/weapon_pickup.tscn").instantiate()
		#self.get_parent().add_child(_pickup)
		
		# Had some problems spawning the item pickup on the platform...
		# It would spawn, but would start sliding around for some reason. 
		# Setting velocity to 0 didn't fix it. Not sure what's going on.
		# So I just reparented to the spawner controller and spawned it above the platform. 
		# This is likely to cause problems later as it might fall through or not be reliable. 
		add_child(weapon_pickup)	# Set parent to spawner, not platform
		weapon_pickup.position = get_node("Item Spawn Position").position
		
	bar.value = health
	barText.text = str(health)

func recalibrate():
	#if playerY: global_position.y += player.global_position.y - playerY
	global_position.x = player.global_position.x - $EnemyShape.shape.size.x*.42 + player.get_node("CollisionShape2D").shape.size.x
	#playerY = player.global_position.y
	if weapon_pickup != null && is_instance_valid(weapon_pickup):
		weapon_pickup.position.x = get_node("Item Spawn Position").position.x
	

func _on_contact_damage_body_entered(body):
	if $ContactDamage.visible and body.collision_layer == 65: #damage player
		var left := false if body.position.x > position.x else true
		body.take_damage(left, 1, true)
