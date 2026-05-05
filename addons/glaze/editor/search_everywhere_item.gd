@tool
extends Control

const SELECTED_COLOR:= Color(0.1, 0.6, 1, 0.5)
# Check here: https://godotengine.github.io/editor-icons/
const SUFFIX_TO_ICONS:= {
	"gd": "GDScript",
	"tscn": "PackedScene",
	"svg": "Image",
	"png": "Image",
	"jpg": "Image",
	"txt": "TextFile",
	"json": "TextFile",
	"xml": "TextFile",
	"properties": "TextFile",
}

var keyword: String
var file: SearchEverywhere.File
var search: SearchEverywhere

var selected:= false
var hovered:= false

func init_item(keyword: String, file: SearchEverywhere.File, search: SearchEverywhere) -> void:
	self.keyword = keyword
	self.file = file
	self.search = search
	if keyword:
		var i = file.name.findn(keyword)
		var s:= ["", "", ""]
		s[0] = file.name.substr(0, i)
		s[1] = file.name.substr(i, keyword.length())
		s[2] = file.name.substr(i + keyword.length())
		%FileNameLabel.text = "%s[b]%s[/b]%s" % s
	else:
		%FileNameLabel.text = file.name
	%DirPathLabel.text = "res:/%s" % file.full_path
	var base:= EditorInterface.get_base_control()
	var lower_name:= file.name.to_lower()
	var suffix:= ""
	var dot = lower_name.rfind(".")
	if dot >= 0:
		suffix = lower_name.substr(dot + 1)
	if suffix in SUFFIX_TO_ICONS:
		%IconRect.texture = base.get_theme_icon(SUFFIX_TO_ICONS[suffix], "EditorIcons")
	else:
		%IconRect.texture = base.get_theme_icon("File", "EditorIcons")

func _process(delta: float) -> void:
	get_theme_stylebox("panel").bg_color = SELECTED_COLOR if selected or hovered else Color.TRANSPARENT

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		search._open_file(file.full_path)
