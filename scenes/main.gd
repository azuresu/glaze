extends Node3D

var fps: String:
	get: return "FPS: %d" % Engine.get_frames_per_second()

var version: String:
	get: return _version.format()

var click_text: String:
	get: return "Clicks: %s" % _clicks

var _version:= Version.new()
var _clicks:= 0

func _ready() -> void:
	_version.load_from_file("res://version.json")
	Glaze.new_scene("ball", self)
	Glaze.new_scene("ball2", self)

func update_time(delta: float) -> void:
	%Time.text = str(Time.get_ticks_msec())

func _click_me() -> void:
	_clicks += 1
