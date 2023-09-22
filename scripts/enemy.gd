extends CharacterBody2D

var camera

var isPlatform = false

func _ready():
	velocity.y = 50

func _physics_process(_delta):
	move_and_slide()
	if camera and position.y > (camera.get_screen_center_position().y + 400):
		queue_free()

func set_camera(cam):
	camera = cam

func change():
	velocity.x = 0
	isPlatform = true
	$Sprite2D.texture = ResourceLoader.load("res://assets/sprites/platform.png")
	$PlatformBody.visible = true
	$ContactDamage.visible = false
	set_collision_layer_value(6, 1)
	set_collision_layer_value(2, 0)
	set_collision_mask_value(1, 0)

func _on_contact_damage_body_entered(body):
	if $ContactDamage.visible and body.collision_layer == 1: #damage player
		get_tree().reload_current_scene()
