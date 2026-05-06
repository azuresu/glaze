@tool
class_name SearchEverywhere extends Window

const LINE_FOUND_MAX:= 5

static var item_scene = preload("res://addons/glaze/editor/search_everywhere_item.tscn")
static var text_suffixes = [".txt", ".tscn", ".tres", ".json", ".csv", ".xml", ".properties", ".md"]

var text_search_keyword: String
var text_search_files: Array[File]
var text_search_thread:= Thread.new()
var text_search_semaphore:= Semaphore.new()

var _exited: bool

func _ready() -> void:
	text_search_thread = Thread.new()
	text_search_thread.start(_search_text_files, Thread.PRIORITY_LOW)

func _process(delta: float) -> void:
	%CountLabel.text = "Found: %s" % %ResultList.get_child_count()

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
	text_search_keyword = ""
	text_search_files.clear()
	for ch in %ResultList.get_children():
		ch.free_item()
	if %Keyword.text:
		var options:= Options.new()
		options.keyword = %Keyword.text
		options.addons = %Addons.button_pressed
		options.uid = %UID.button_pressed
		options.import = %Import.button_pressed
		options.searchInFiles = %SearchInFiles.button_pressed
		var files: Array[File]
		_list_files(options, "", files, text_search_files)
		files.sort_custom(func(f1, f2) -> bool: return f1.full_path.length() < f2.full_path.length())
		for f in files:
			_add_result(f)
		text_search_keyword = options.keyword
		text_search_semaphore.post()

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

func _add_result(f: File) -> void:
	for ch in %ResultList.get_children():
		if ch.visible and ch.file == f:
			ch.update_ui()
			return
	var item = item_scene.instantiate()
	item.init_item(f, self)
	%ResultList.add_child(item)
	if not _get_selected_file():
		_select_result(0)

func _list_files(options: Options, dir_path: String, files: Array[File], text_files: Array[File]) -> void:
	var dir:= DirAccess.open("res://%s" % dir_path)
	if dir:
		if dir_path.begins_with("/addons/") and not options.addons:
			return
		for f in dir.get_files():
			if f.ends_with(".uid") and not options.uid:
				continue
			if f.ends_with(".import") and not options.import:
				continue
			var file = File.new(dir_path, f)
			if f.containsn(options.keyword):
				file.keyword = options.keyword
				files.append(file)
			if options.searchInFiles and _is_text(f):
				text_files.append(file)
		for sub_path in dir.get_directories():
			if not sub_path.begins_with("."):
				_list_files(options, "%s/%s" % [dir_path, sub_path], files, text_files)

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

func _is_text(filename: String) -> bool:
	var lower:= filename.to_lower()
	for s in text_suffixes:
		if lower.ends_with(s):
			return true
	return false

func _search_text_files() -> void:
	while not _exited:
		text_search_semaphore.wait()
		for i in text_search_files.size():
			var k:= text_search_keyword
			var f:= text_search_files[i]
			if k and f:
				var fa = FileAccess.open("res://%s" % f.full_path, FileAccess.READ)
				var ln = 0
				while not fa.eof_reached():
					k = text_search_keyword
					if k:
						var line:= fa.get_line()
						ln += 1
						if line.containsn(k):
							f.keyword = k
							f.lines[ln] = line
							call_deferred("_add_result", f)
							if f.lines.size() >= LINE_FOUND_MAX:
								break
					else:
						break
				fa.close()
			else:
				break

func _on_keyword_text_changed(new_text: String) -> void:
	_search()

func _on_addons_toggled(toggled_on: bool) -> void:
	_search()

func _on_uid_toggled(toggled_on: bool) -> void:
	_search()

func _on_import_toggled(toggled_on: bool) -> void:
	_search()

func _on_search_in_files_toggled(toggled_on: bool) -> void:
	_search()

func _exit_tree() -> void:
	_exited = true

class Options:

	var keyword: String
	var addons: bool
	var uid: bool
	var import: bool
	var searchInFiles: bool

class File:

	var keyword: String
	var dir_path: String
	var name: String
	var full_path: String:
		get: return "%s/%s" % [dir_path, name]
	var lines: Dictionary[int, String]

	func _init(dir_path: String, name: String) -> void:
		self.dir_path = dir_path
		self.name = name
