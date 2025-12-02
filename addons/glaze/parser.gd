class_name Parser extends RefCounted

static var builtin_parsers: Array[Parser] = [
	Vector2Parser.new(),
	Vector2iParser.new(),
	Vector3Parser.new(),
	Vector3iParser.new(),
	ColorParser.new(),
]

func can_parse(s: String) -> bool:
	return false

func parse(s: String) -> Variant:
	return null

func can_format(v: Variant) -> bool:
	return false

func format(v: Variant) -> String:
	return ""

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
		return "Vector3(%s,%s)" % [v.x, v.y, v.z]

class Vector3iParser extends Parser:

	func can_parse(s: String) -> bool:
		return s.begins_with("Vector3i(") and s.ends_with(")")

	func parse(s: String) -> Variant:
		var xy = s.substr(9, s.length() - 10).split(",")
		return Vector3i(int(xy[0]), int(xy[1]), int(xy[2]))

	func can_format(v: Variant) -> bool:
		return v is Vector3i

	func format(v: Variant) -> String:
		return "Vector3i(%s,%s)" % [v.x, v.y, v.z]

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
