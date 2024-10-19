extends Node2D

@export var Explosion : PackedScene
@export var EMP_effect : PackedScene

signal enemy_projectiles_destroyed
signal time_freeze(time_speed)

var freeze_duration = 3.0
var time_freeze_active = false
var time_freeze_alarm := 0.0
var time_speed := 1.0
var freeze_effect = null

# Gadget behaviour
func gadget_grenade():
	print("Used Grenade")
	var boom = Explosion.instantiate()
	call_deferred("add_child", boom)
	boom.scale = Vector2(2.5,2.5)
	boom.position = position
	boom.setup(25, null)

func gadget_emp():
	print("Used EMP")
	# Deletes all enemy projectiles on screen
	enemy_projectiles_destroyed.emit()
	
	# Spawn effect
	var _effect = EMP_effect.instantiate()
	_effect.global_position = Global.player.global_position
	get_tree().get_root().add_child(_effect)

func gadget_photon_barrier():
	print("Used Photon Barrier")
	# Create a barrier in front of the player which blocks enemy shots
	# can also be jump on
	var _platform = load("res://scenes/photon_barrier_platform.tscn").instantiate()
	Global.Spawner.add_child(_platform)
	_platform.global_position = Global.player.global_position
	_platform.global_position.y -= 64

func gadget_time_freeze():
	print("Used Time Freeze")
	# Get all enemies, projectiles
	# set their delta to 0 for a period of time
	time_freeze_start()

func gadget_portal_trinket():
	print("Used Portal Trinket")
	# throws a grenade like a rocket
	# when it hits an enemy, player and enemy swap places
	# If it hits a boss, it deals damage instead
	# deletes when on thrown off screen
	
	var _projectile = load("res://scenes/portal_trinket_projectile.tscn").instantiate()
	Global.player.get_node("Projectiles").add_child(_projectile)
	_projectile.global_position = Global.player.global_position
	_projectile.fire(get_global_mouse_position(), Global.player.global_position, 10, 0)

func use():
	
	match Global.player.gadget_current:
		Global.PICKUP.grenade: 			gadget_grenade()
		Global.PICKUP.EMP: 				gadget_emp()
		Global.PICKUP.Photon_Barrier: 	gadget_photon_barrier()
		Global.PICKUP.Time_Freeze:		gadget_time_freeze()
		Global.PICKUP.Portal_Trinket:	gadget_portal_trinket()
	
	Global.player.gadget_current = -1

func _process(delta):
	
	time_freeze_process(delta)
	
	pass

func time_freeze_start():
	time_freeze_active = true
	time_freeze_alarm = freeze_duration
	time_speed = 0
	time_freeze.emit(time_speed)
	
	freeze_effect = load("res://scenes/time_freeze_clock.tscn").instantiate()
	Global.BackgroundLayer.add_child(freeze_effect)
	

func time_freeze_process(delta):
	# time freeze effect
	if time_freeze_alarm > 0:
		time_freeze_alarm = max(0, time_freeze_alarm - delta)
		
		# freeze time
		if time_freeze_alarm > 0:
			pass
		# end freeze time
		else:
			time_freeze_end()

func time_freeze_end():
	time_freeze_active = false
	time_speed = 1
	time_freeze.emit(time_speed)
	
	if freeze_effect != null:
		freeze_effect.queue_free()
	
