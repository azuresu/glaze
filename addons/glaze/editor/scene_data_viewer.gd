@tool
extends Control

func _ready() -> void:
	_update_table()

func _update_table() -> void:
	var filter_text: String = %Filter.text
	for ch in %Table.get_children():
		ch.free()
	var props:= {}
	for name in Glaze.scene_data:
		if not filter_text or name.contains(filter_text):
			var data: Dictionary = Glaze.scene_data[name]
			for key in data:
				props[key] = 1
	%Table.columns = props.size() + 1

	_add_table_cell("SCENE_NAME", true)
	for k in props:
		_add_table_cell(k, true)

	var count:= 0
	for name: String in Glaze.scene_data:
		if not filter_text or name.contains(filter_text):
			count += 1
			var data: Dictionary = Glaze.scene_data[name]
			_add_table_cell(name)
			_add_table_row(data, props.keys())
	%Result.text = "Found %s result(s)" % count

func _add_table_cell(value: Variant, head:= false) -> void:
	var cell_style:= _new_cell_style()
	var cell_label = Label.new()
	cell_label.set("theme_override_styles/normal", cell_style)
	var s:= str(value)
	if head:
		var fv:= FontVariation.new()
		fv.variation_embolden = 0.5
		cell_label.set("theme_override_fonts/font", fv)
		s = s.to_upper()
	cell_label.text = s
	%Table.add_child(cell_label)

func _add_table_head(heads: Array) -> void:
	for h in heads:
		_add_table_cell(h, true)

func _add_table_row(dict: Dictionary, keys: Array) -> void:
	for k in keys:
		var v = ""
		if k in dict:
			v = dict[k]
		_add_table_cell(v)

func _new_cell_style() -> StyleBoxFlat:
	var even: bool = (%Table.get_child_count() / %Table.columns) % 2 == 0
	var last: bool = (%Table.get_child_count() + 1) % %Table.columns == 0
	var s:= StyleBoxFlat.new()
	s.content_margin_top = 5
	s.content_margin_bottom = 5
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.bg_color = Color(0, 0, 0, 0.05) if even else Color(1, 1, 1, 0.05)
	if not last:
		s.border_color = Color(1, 1, 1, 0.15)
		s.border_width_right = 1.0
	return s

func _on_filter_text_changed(new_text: String) -> void:
	_update_table()

func _on_draw() -> void:
	Glaze.load_config()
	_update_table()
