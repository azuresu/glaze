@tool
class_name SearchEverywhere extends Window

static var item_scene = preload("res://addons/glaze/editor/search_everywhere_item.tscn")

func _on_close_requested() -> void:
	hide()

func _on_focus_exited() -> void:
	hide()

func _on_about_to_popup() -> void:
	%Keyword.grab_focus()
	%Keyword.select(0, %Keyword.text.length())

func _on_keyword_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var file:= _get_selected_file()
		if file:
			match event.keycode:
				KEY_ENTER:
					_open_file("res://%s" % file.full_path)
					hide()
				KEY_UP:
					_move_select_result(-1)
					%Keyword.grab_focus()
				KEY_DOWN:
					_move_select_result(1)
					%Keyword.grab_focus()
				KEY_ESCAPE:
					hide()

func _search() -> void:
	for ch in %ResultList.get_children():
		ch.free()
	var keyword: String = %Keyword.text
	var addons: bool = %Addons.button_pressed
	var uid: bool = %UID.button_pressed
	var import: bool = %Import.button_pressed
	if keyword:
		var files: Array[File]
		_list_files("", files)
		for i in range(files.size() - 1, -1, -1):
			var f:= files[i]
			if f.dir_path.begins_with("/addons/") and not addons:
				files.remove_at(i)
			elif f.name.ends_with(".uid") and not uid:
				files.remove_at(i)
			elif f.name.ends_with(".import") and not import:
				files.remove_at(i)
			elif not f.name.containsn(keyword):
				files.remove_at(i)
		files.sort_custom(func(f1, f2) -> bool: return f1.full_path.length() < f2.full_path.length())
		for f in files:
			var item = item_scene.instantiate()
			item.init_item(keyword, f, self)
			%ResultList.add_child(item)
		_select_result(0)

func _get_selected_file() -> File:
	for ch in %ResultList.get_children():
		if ch.selected:
			return ch.file
	return null

func _select_result(index: int) -> void:
	if index >= 0 and index < %ResultList.get_child_count():
		for i in %ResultList.get_child_count():
			%ResultList.get_child(i).selected = i == index

func _move_select_result(offset: int) -> void:
	for i in %ResultList.get_child_count():
		if %ResultList.get_child(i).selected:
			if offset < 0:
				_select_result(i - 1)
			elif offset > 0:
				_select_result(i + 1)
			break

func _list_files(dir_path: String, files: Array[File]) -> void:
	var dir:= DirAccess.open("res://%s" % dir_path)
	if dir:
		for f in dir.get_files():
			files.append(File.new(dir_path, f))
		for sub_path in dir.get_directories():
			if not sub_path.begins_with("."):
				_list_files("%s/%s" % [dir_path, sub_path], files)

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

func _on_import_toggled(toggled_on: bool) -> void:
	_search()

class File:
	
	var dir_path: String
	var name: String
	var full_path: String:
		get: return "%s/%s" % [dir_path, name]

	func _init(dir_path: String, name: String) -> void:
		self.dir_path = dir_path
		self.name = name
