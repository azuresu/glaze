@tool
extends EditorPlugin

var scene_data_viewer: Control
var translation_viewer: Control
var search_everywhere: Window

var _search_press_count: int
var _search_press_timeout: float

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
	search_everywhere = preload("res://addons/glaze/editor/search_everywhere.tscn").instantiate()
	EditorInterface.get_base_control().add_child(search_everywhere)
	search_everywhere.hide()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(scene_data_viewer)
	scene_data_viewer.free()
	remove_control_from_bottom_panel(translation_viewer)
	translation_viewer.free()
	search_everywhere.free()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_SHIFT:
		var s:= 0
		if event.pressed and _search_press_count % 2 == 0:
			s = 1
		elif not event.pressed and _search_press_count % 2 == 1:
			s = 1
		_search_press_count += s
		_search_press_timeout = 0.15
		if _search_press_count == 4:
			_search_press_count = 0
			_search_press_timeout = 0
			search_everywhere.popup_centered()

func _process(delta: float) -> void:
	_search_press_timeout = maxf(0, _search_press_timeout - delta)
	if _search_press_timeout == 0:
		_search_press_count = 0
