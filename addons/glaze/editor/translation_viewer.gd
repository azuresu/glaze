@tool
extends Control

var language_checkboxes: Dictionary[String, CheckBox]

func _ready() -> void:
	_update_table()

func _update_table(update_csv:= false) -> void:
	Glaze.free_children(%Table)
	var merged_bundles: Dictionary[String, Dictionary]
	var merged_keys: Dictionary[String, int]
	var files_to_reimport: PackedStringArray
	for trans_file in Glaze.translation_files:
		if trans_file is String and FileAccess.file_exists(trans_file) and trans_file.ends_with(".csv"):
			var bundles: Dictionary[String, Dictionary]
			var file_dir:= "."
			var file_name: String = trans_file.substr(0, trans_file.length() - 4)
			var sep:= file_name.rfind("/")
			if sep == -1:
				sep = file_name.rfind("\\")
			if sep >= 0:
				file_dir = file_name.substr(0, sep)
				file_name = file_name.substr(sep + 1)
			for lang in Glaze.translation_languages:
				if not lang in language_checkboxes:
					var box:= CheckBox.new()
					box.button_pressed = true
					box.toggled.connect(func(toggled_on): _update_table())
					language_checkboxes[lang] = box
					%LanguageBar.add_child(box)
			for lang in Glaze.translation_languages:
				var prop_file:= "%s/%s_%s.txt" % [file_dir, file_name, lang]
				if FileAccess.file_exists(prop_file):
					var props: Dictionary
					_load_properties(prop_file, props)
					for k in props:
						merged_keys[k] = 1
					bundles[lang] = props
					if not lang in merged_bundles:
						merged_bundles[lang] = {}
					merged_bundles[lang].merge(props)
			if update_csv and Glaze.translation_languages:
				var lang: String = Glaze.translation_languages[0]
				var sorted_keys: Array[String]
				for k in bundles[lang]:
					sorted_keys.append(k)
				sorted_keys.sort_custom(func(s1, s2): return s1.naturalnocasecmp_to(s2) < 0)
				var csv_file = FileAccess.open(trans_file, FileAccess.WRITE)
				var head:= "keys"
				for k in bundles:
					head += ",%s" % k
				csv_file.store_line(head)
				for k in bundles[lang]:
					var ln = k
					for k2 in bundles:
						ln = _append_csv_line(ln, k, bundles[k2])
					csv_file.store_line(ln)
				files_to_reimport.append(trans_file)
	if files_to_reimport:
		EditorInterface.get_resource_filesystem().reimport_files(files_to_reimport)

	var cols:= 1
	for lang in language_checkboxes:
		if language_checkboxes[lang].button_pressed:
			cols += 1
	%Table.columns = cols

	var filter_text: String = %Filter.text
	var key_count: Dictionary[String, int]
	%Table.add_table_cell("KEY", true)
	for lang in merged_bundles:
		key_count[lang] = 0
		if language_checkboxes[lang].button_pressed:
			%Table.add_table_cell(lang, true)
	for k: String in merged_keys:
		if not filter_text or k.contains(filter_text):
			%Table.add_table_cell(k)
			for lang in merged_bundles:
				var props = merged_bundles[lang]
				if k in props:
					key_count[lang] += 1
				if language_checkboxes[lang].button_pressed:
					if k in props:
						%Table.add_table_cell(props[k])
					else:
						%Table.add_table_cell("")
	for lang in key_count:
		language_checkboxes[lang].text = "%s(%d)" % [lang, key_count[lang]]

func _load_properties(filename: String, props: Dictionary):
	var read_file:= FileAccess.open(filename, FileAccess.READ)
	while read_file.get_position() < read_file.get_length():
		var ln:= read_file.get_line()
		var eq:= ln.find("=")
		if eq >= 0:
			var key:= ln.substr(0, eq)
			var str:= ln.substr(eq + 1)
			props[key] = str
	read_file.close()

func _append_csv_line(line: String, key: String, strings: Dictionary) -> String:
	var str:= key
	if key in strings:
		str = strings[key]
	var new_str:= ""
	var words:= str.split("\"")
	for w in words:
		if new_str.length():
			new_str += "\"\"%s" % w
		else:
			new_str += w
	if new_str.find(",") >= 0:
		new_str = "\"%s\"" % new_str
	line += ",%s" % new_str
	return line

func _on_draw() -> void:
	Glaze.load_config()
	_update_table()

func _on_filter_text_changed(new_text: String) -> void:
	_update_table()

func _on_update_csv_button_pressed() -> void:
	_update_table(true)
