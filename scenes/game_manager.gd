extends Node2D
var starter_weapons : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_weapon_pick_up(picked_weapon) -> void:
	for weapon in starter_weapons:
		if weapon != picked_weapon:
			weapon.queue_free()
