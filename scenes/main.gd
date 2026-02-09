extends Node3D

var fps: String:
	get: return "FPS: %d" % Engine.get_frames_per_second()

var version: String:
	get: return _version.as_string()

var click_text: String:
	get: return "Clicks: %s" % _clicks

var _version:= Version.load_from_file("res://version.json")
var _clicks:= 0

func _ready() -> void:
	Glaze.new_scene("ball", self)
	Glaze.new_scene("ball2", self)

func update_time(delta: float) -> void:
	%Time.text = str(Time.get_ticks_msec())

func _click_me() -> void:
	_clicks += 1
