extends Node3D

func _ready() -> void:
	Glaze.new_scene("ball", self)
	Glaze.new_scene("ball2", self)
	%Version.text = "Version: %s" % Version.load_from_file("res://data/version.json")
