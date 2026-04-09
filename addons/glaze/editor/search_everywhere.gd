@tool
extends Window

func _on_close_requested() -> void:
	hide()

func _on_focus_exited() -> void:
	hide()

func _on_about_to_popup() -> void:
	%Keyword.grab_focus()
	%Keyword.select(0, %Keyword.text.length())

func _on_keyword_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and %Result.get_selected_items():
		var sel: int = %Result.get_selected_items()[0]
		match event.keycode:
			KEY_ENTER:
				_open_file("res://%s" % %Result.get_item_text(sel))
				hide()
			KEY_UP:
				if sel > 0:
					%Result.select(sel - 1)
					%Keyword.grab_focus()
			KEY_DOWN:
				if sel < %Result.item_count - 1:
					%Result.select(sel + 1)
					%Keyword.grab_focus()
			KEY_ESCAPE:
				hide()

func _search() -> void:
	%Result.clear()
	var keyword: String = %Keyword.text
	var addons: bool = %Addons.button_pressed
	var uid: bool = %UID.button_pressed
	if keyword:
		var files: Array[File]
		_list_files("", files)
		for f in files:
			if f.path.begins_with("/addons/") and not addons:
				continue
			if f.name.ends_with(".uid") and not uid:
				continue
			if f.name.containsn(keyword):
				%Result.add_item("%s/%s" % [f.path, f.name])
		if %Result.item_count:
			%Result.select(0)

func _list_files(path: String, files: Array[File]) -> void:
	var dir:= DirAccess.open("res://%s" % path)
	if dir:
		for f in dir.get_files():
			files.append(File.new(path, f))
		for sub in dir.get_directories():
			if not sub.begins_with("."):
				_list_files("%s/%s" % [path, sub], files)

func _open_file(path: String) -> void:
	if path.ends_with(".tscn"):
		EditorInterface.open_scene_from_path(path)
		var res = load(path)
		if res is PackedScene:
			var root_type = res.get_state().get_node_type(0)
			if ClassDB.is_parent_class(root_type, "Node3D"):
				EditorInterface.set_main_screen_editor("3D")
			else:
				EditorInterface.set_main_screen_editor("2D")
	elif path.ends_with(".gd"):
		EditorInterface.edit_script(load(path))
		EditorInterface.set_main_screen_editor("Script")
	else:
		EditorInterface.edit_resource(load(path))

func _on_keyword_text_changed(new_text: String) -> void:
	_search()

func _on_addons_toggled(toggled_on: bool) -> void:
	_search()

func _on_uid_toggled(toggled_on: bool) -> void:
	_search()

class File:
	
	var path: String
	var name: String

	func _init(path: String, name: String) -> void:
		self.path = path
		self.name = name
