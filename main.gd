extends Node3D

func _ready() -> void:
	Glaze.new_scene("ball", self).position.x = -1
	Glaze.new_scene("ball2", self).position.x = 1
