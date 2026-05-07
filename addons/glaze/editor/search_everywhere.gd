@tool
class_name SearchEverywhere extends Window

const RELATIVE_SIZE:= Vector2(0.5, 0.7)
const MINIMUM_SIZE:= Vector2i(600, 400)

static var item_scene = preload("res://addons/glaze/editor/search_everywhere_item.tscn")

var _opened_once: bool

func open() -> void:
	if not _opened_once:
		_opened_once = true
		var popup_size:= DisplayServer.window_get_size()
		popup_size.x = maxi(MINIMUM_SIZE.x, popup_size.x * RELATIVE_SIZE.x)
		popup_size.y = maxi(MINIMUM_SIZE.y, popup_size.y * RELATIVE_SIZE.y)
		size = popup_size
	popup_centered()

func open_file(path: String) -> void:
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
	hide()

func search() -> void:
	for ch in %ResultList.get_children():
		ch.free()
	if %Keyword.text:
		var options:= Options.new()
		options.keyword = %Keyword.text
		options.addons = %Addons.button_pressed
		options.uid = %UID.button_pressed
		options.import = %Import.button_pressed
		options.searchInFiles = %SearchInFiles.button_pressed
		$Worker.search(options)

func _ready() -> void:
	$Worker.progress_updated.connect(_on_progress_updated)
	$Worker.file_found.connect(_on_file_found)
	pass

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
		match event.keycode:
			KEY_ENTER:
				var file:= _get_selected_file()
				if file:
					open_file("res://%s" % file.full_path)
			KEY_UP:
				_move_select_result(-1)
				%Keyword.grab_focus()
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_move_select_result(1)
				%Keyword.grab_focus()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				hide()

func _get_selected_file() -> File:
	for ch in %ResultList.get_children():
		if ch.selected:
			return ch.file
	return null

func _select_result(index: int) -> void:
	if index >= 0 and index < %ResultList.get_child_count():
		for i in %ResultList.get_child_count():
			var item:= %ResultList.get_child(i)
			item.selected = i == index
			if item.selected:
				%ResultScroll.ensure_control_visible(item)
				%ResultScroll.scroll_horizontal = 0

func _move_select_result(offset: int) -> void:
	for i in %ResultList.get_child_count():
		if %ResultList.get_child(i).selected:
			if offset < 0:
				_select_result(i - 1)
			elif offset > 0:
				_select_result(i + 1)
			return
	# Select first one in default.
	_select_result(0)

func _on_progress_updated(index: int, total: int) -> void:
	%ProgressBar.max_value = total
	%ProgressBar.value = index

func _on_file_found(f: File) -> void:
	for ch in %ResultList.get_children():
		if ch.file == f:
			ch.update_ui()
			return
	var item = item_scene.instantiate()
	item.init_item(f, self)
	%ResultList.add_child(item)
	if not _get_selected_file():
		_select_result(0)

func _on_keyword_text_changed(new_text: String) -> void:
	search()

func _on_addons_toggled(toggled_on: bool) -> void:
	search()

func _on_uid_toggled(toggled_on: bool) -> void:
	search()

func _on_import_toggled(toggled_on: bool) -> void:
	search()

func _on_search_in_files_toggled(toggled_on: bool) -> void:
	search()

func _exit_tree() -> void:
	$Worker.stop()

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
	var lines_more: bool

	func _init(dir_path: String, name: String) -> void:
		self.dir_path = dir_path
		self.name = name
