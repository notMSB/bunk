extends Node2D

@export var Explosion : PackedScene

signal enemy_projectiles_destroyed

func use():
	
	# Gadget behaviour
	match Global.player.gadget_current:
		
		Global.PICKUP.grenade:
			print("Used Grenade")
			var boom = Explosion.instantiate()
			call_deferred("add_child", boom)
			boom.scale = Vector2(2.5,2.5)
			boom.position = position
			boom.setup(25, null)
		
		Global.PICKUP.EMP:
			print("Used EMP")
			# Deletes all enemy projectiles on screen
			enemy_projectiles_destroyed.emit()
			pass
		
		Global.PICKUP.Photon_Barrier:
			print("Used Photon Barrier")
			# Create a barrier in front of the player which blocks enemy shots
			# can also be jump on
			pass
		
		Global.PICKUP.Time_Freeze:
			print("Used Time Freeze")
			# Get all enemies, projectiles
			# set their delta to 0 for a period of time
			pass
		
		Global.PICKUP.Portal_Trinket:
			print("Used Portal Trinket")
			# throws a grenade like a rocket
			# when it hits an enemy, player and enemy swap places
			# If it hits a boss, it deals damage instead
			# deletes when on thrown off screen
			pass
	
	
	
	Global.player.gadget_current = -1
