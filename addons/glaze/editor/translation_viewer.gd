@tool
extends Control

func _ready() -> void:
	_update_table()

func _update_table() -> void:
	Glaze.free_children(%Table)
	var bundles: Dictionary
	for trans_file in Glaze.translation_files:
		if trans_file is String and FileAccess.file_exists(trans_file) and trans_file.ends_with(".csv"):
			trans_file = trans_file.substr(0, trans_file.length() - 4)
			var file_dir:= "."
			var file_name: String = trans_file
			var sep:= file_name.rfind("/")
			if sep == -1:
				sep = file_name.rfind("\\")
			if sep >= 0:
				file_dir = file_name.substr(0, sep)
				file_name = file_name.substr(sep + 1)
			for lang in Glaze.translation_languages:
				var prop_file:= "res://%s/%s_%s.txt" % [file_dir, file_name, lang]
				if FileAccess.file_exists(prop_file):
					var props: Dictionary
					_load_properties(prop_file, props)
					bundles[lang] = props
	
	%Table.columns = bundles.size() + 1

	%Table.add_table_cell("KEY", true)
	for lang in bundles:
		%Table.add_table_cell(lang, true)

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

func _on_draw() -> void:
	Glaze.load_config()
	_update_table()
