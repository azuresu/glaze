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

	_add_table_cell("SCENE NAME", true)
	for k in props:
		_add_table_cell(k, true)

	for name: String in Glaze.scene_data:
		if not filter_text or name.contains(filter_text):
			var data: Dictionary = Glaze.scene_data[name]
			_add_table_cell(name)
			_add_table_row(data, props.keys())

func _add_table_cell(value: Variant, head:= false) -> void:
	var even: bool = (%Table.get_child_count() / %Table.columns) % 2 == 0
	var row_style:= StyleBoxFlat.new()
	row_style.set_content_margin_all(4)
	row_style.bg_color = Color(0, 0, 0, 0.2) if even else Color(1, 1, 1, 0.2)
	var l = Label.new()
	l.set("theme_override_styles/normal", row_style)
	var s:= str(value)
	if head:
		var fv:= FontVariation.new()
		fv.variation_embolden = 0.5
		l.set("theme_override_fonts/font", fv)
		s = s.to_upper()
	l.text = s
	%Table.add_child(l)

func _add_table_head(heads: Array) -> void:
	for h in heads:
		_add_table_cell(h, true)

func _add_table_row(dict: Dictionary, keys: Array) -> void:
	for k in keys:
		var v = ""
		if k in dict:
			v = dict[k]
		_add_table_cell(v)

func _on_filter_text_changed(new_text: String) -> void:
	_update_table()

func _on_draw() -> void:
	Glaze.reload()
	_update_table()
