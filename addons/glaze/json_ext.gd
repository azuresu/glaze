class_name JsonExt extends Object

enum Error {
	TEXT_NOT_JSON, TEXT_NOT_JSON_DICT, TEXT_NOT_JSON_ARRAY,
	FILE_NOT_FOUND
}

static var builtin_parsers: Array[Parser] = [
	Vector2Parser.new(),
	Vector2iParser.new(),
	Vector3Parser.new(),
	Vector3iParser.new(),
	ColorParser.new(),
]

var _parsers: Array[Parser]

func add_parser(parser: Parser) -> void:
	var i:= _parsers.find(parser)
	if i == -1:
		_parsers.append(parser)

func remove_parser(parser: Parser) -> void:
	var i:= _parsers.find(parser)
	if i >= 0:
		_parsers.remove_at(i)

func add_builtin_parsers() -> void:
	for p in builtin_parsers:
		add_parser(p)

## Parses JSON from text.
func parse(text: String, error_handler: Callable) -> Variant:
	var json = JSON.new()
	var error = json.parse(text)
	if not error:
		if _parsers:
			return _parse_value(json.data)
		else:
			return json.data
	else:
		return error_handler.call(Error.TEXT_NOT_JSON)

## Format JSON to text.
func format(json: Variant) -> String:
	if _parsers:
		json = _format_value(json)
	return JSON.stringify(json)

## Parses JSON as dictionary from text.
func parse_as_dict(text: String, error_handler:= func(error: Error): return {}) -> Dictionary:
	var json = parse(text, error_handler)
	if json is Dictionary:
		return json
	return error_handler.call(Error.TEXT_NOT_JSON_DICT)

## Parses JSON as array from text.
func parse_as_array(text: String, error_handler:= func(error: Error): return []) -> Array:
	var json = parse(text, error_handler)
	if json is Array:
		return json
	return error_handler.call(Error.TEXT_NOT_JSON_ARRAY)

## Loads JSON as dictionary from file.
func load_file_as_dict(filename: String, error_handler:= func(error: Error): return {}) -> Dictionary:
	var json = JSON.new()
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		return parse_as_dict(text, error_handler)
	return error_handler.call(Error.FILE_NOT_FOUND)

## Loads JSON as array from file.
func load_file_as_array(filename: String, error_handler:= func(error: Error): return []) -> Array:
	var json = JSON.new()
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		return parse_as_array(text, error_handler)
	return error_handler.call(Error.FILE_NOT_FOUND)

## Parses given argument with built-in parsers.
func _parse_value(value: Variant) -> Variant:
	if value is Array:
		for i in value.size():
			value[i] = _parse_value(value[i])
	elif value is Dictionary:
		for k in value:
			value[k] = _parse_value(value[k])
	elif value is String:
		for p in _parsers:
			if p.can_parse(value):
				return p.parse(value)
	return value

## Formats given argument with built-in parsers.
func _format_value(value: Variant) -> Variant:
	if value is Array:
		for i in value.size():
			value[i] = _format_value(value[i])
	elif value is Dictionary:
		for k in value:
			value[k] = _format_value(value[k])
	else:
		for p in _parsers:
			if p.can_format(value):
				return p.format(value)
	return value

class Parser extends RefCounted:

	func can_parse(s: String) -> bool:
		return false

	func parse(s: String) -> Variant:
		return s

	func can_format(v: Variant) -> bool:
		return false

	func format(v: Variant) -> String:
		return v

class Vector2Parser extends Parser:

	func can_parse(s: String) -> bool:
		return s.begins_with("Vector2(") and s.ends_with(")")

	func parse(s: String) -> Variant:
		var xy = s.substr(8, s.length() - 9).split(",")
		return Vector2(float(xy[0]), float(xy[1]))

	func can_format(v: Variant) -> bool:
		return v is Vector2

	func format(v: Variant) -> String:
		return "Vector2(%s,%s)" % [v.x, v.y]

class Vector2iParser extends Parser:

	func can_parse(s: String) -> bool:
		return s.begins_with("Vector2i(") and s.ends_with(")")
	
	func parse(s: String) -> Variant:
		var xy = s.substr(9, s.length() - 10).split(",")
		return Vector2i(int(xy[0]), int(xy[1]))

	func can_format(v: Variant) -> bool:
		return v is Vector2i

	func format(v: Variant) -> String:
		return "Vector2i(%s,%s)" % [v.x, v.y]

class Vector3Parser extends Parser:

	func can_parse(s: String) -> bool:
		return s.begins_with("Vector3(") and s.ends_with(")")

	func parse(s: String) -> Variant:
		var xy = s.substr(8, s.length() - 9).split(",")
		return Vector3(float(xy[0]), float(xy[1]), float(xy[2]))

	func can_format(v: Variant) -> bool:
		return v is Vector3

	func format(v: Variant) -> String:
		return "Vector3(%s,%s,%s)" % [v.x, v.y, v.z]

class Vector3iParser extends Parser:

	func can_parse(s: String) -> bool:
		return s.begins_with("Vector3i(") and s.ends_with(")")

	func parse(s: String) -> Variant:
		var xy = s.substr(9, s.length() - 10).split(",")
		return Vector3i(int(xy[0]), int(xy[1]), int(xy[2]))

	func can_format(v: Variant) -> bool:
		return v is Vector3i

	func format(v: Variant) -> String:
		return "Vector3i(%s,%s,%s)" % [v.x, v.y, v.z]

class ColorParser extends Parser:

	func can_parse(s: String) -> bool:
		return s.begins_with("Color(") and s.ends_with(")")

	func parse(s: String) -> Variant:
		var html:= s.substr(6, s.length() - 7)
		return Color(html)

	func can_format(v: Variant) -> bool:
		return v is Color

	func format(v: Variant) -> String:
		return "Color(%s)" % v.to_html()
