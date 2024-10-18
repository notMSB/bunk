extends Node2D

func _on_mobile_pressed():
	Global.useMobile = true
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_classic_pressed():
	Global.useMobile = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
