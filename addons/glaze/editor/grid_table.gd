@tool
class_name GridTable extends GridContainer

func add_table_head(heads: Array) -> void:
	for h in heads:
		add_table_cell(h, true)

func add_table_row(dict: Dictionary, keys: Array) -> void:
	for k in keys:
		var v = ""
		if k in dict:
			v = dict[k]
		add_table_cell(v)

func add_table_cell(value: Variant, head:= false) -> void:
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
	add_child(cell_label)

func _new_cell_style() -> StyleBoxFlat:
	var even: bool = (get_child_count() / columns) % 2 == 0
	var last: bool = (get_child_count() + 1) % columns == 0
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
