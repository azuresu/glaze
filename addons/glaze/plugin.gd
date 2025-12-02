@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("Glaze", "res://addons/glaze/glaze.gd")
	print("Plugin Glaze enabled.")

func _disable_plugin() -> void:
	remove_autoload_singleton("Glaze")
	print("Plugin Glaze disabled.")

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	pass
