extends Node2D
@export var starter_weapon_1 : Node2D
@export var starter_weapon_2 : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_weapon_pick_up(picked_weapon) -> void:
	#Messy. Find out why Node2D arrays decide not to work here.
	if starter_weapon_1 != picked_weapon:
			starter_weapon_1.queue_free()
	
	if starter_weapon_2 != picked_weapon:
		starter_weapon_2.queue_free()
