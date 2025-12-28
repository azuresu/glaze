@tool
extends Control

func _ready() -> void:
	_update_table()

func _update_table() -> void:
	Glaze.free_children(%Table)
	var filter_text: String = %Filter.text
	var props:= {}
	for name in Glaze.scene_data:
		if not filter_text or name.contains(filter_text):
			var data: Dictionary = Glaze.scene_data[name]
			for key in data:
				props[key] = 1
	%Table.columns = props.size() + 1

	%Table.add_table_cell("SCENE_NAME", true)
	for k in props:
		%Table.add_table_cell(k, true)

	var count:= 0
	for name: String in Glaze.scene_data:
		if not filter_text or name.contains(filter_text):
			count += 1
			var data: Dictionary = Glaze.scene_data[name]
			%Table.add_table_cell(name)
			%Table.add_table_row(data, props.keys())
	%Result.text = "Found %s result(s)" % count

func _on_filter_text_changed(new_text: String) -> void:
	_update_table()

func _on_draw() -> void:
	Glaze.load_config()
	_update_table()
