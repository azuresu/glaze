@tool
extends EditorPlugin

var scene_data_viewer: Control
var translation_viewer: Control

func _enable_plugin() -> void:
	add_autoload_singleton("Glaze", "res://addons/glaze/glaze.gd")
	print("Plugin Glaze enabled.")

func _disable_plugin() -> void:
	remove_autoload_singleton("Glaze")
	print("Plugin Glaze disabled.")

func _enter_tree() -> void:
	scene_data_viewer = preload("res://addons/glaze/editor/scene_data_viewer.tscn").instantiate()
	add_control_to_bottom_panel(scene_data_viewer, "GLAZE scenes")
	translation_viewer = preload("res://addons/glaze/editor/translation_viewer.tscn").instantiate()
	add_control_to_bottom_panel(translation_viewer, "GLAZE translation")

func _exit_tree() -> void:
	remove_control_from_bottom_panel(scene_data_viewer)
	scene_data_viewer.free()
	remove_control_from_bottom_panel(translation_viewer)
	translation_viewer.free()
