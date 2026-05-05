class_name Version extends RefCounted

var major: int
var minor: int
var patch: int
var build: int

func _to_string() -> String:
	return format()

func format(includes_build:= true) -> String:
	if includes_build:
		return "%s.%s.%s.%s" % [major, minor, patch, build]
	return "%s.%s.%s" % [major, minor, patch]

func parse(s: String) -> bool:
	if s:
		var parts:= s.split(".")
		if parts.size() > 0:
			major = int(parts[0])
		if parts.size() > 1:
			minor = int(parts[1])
		if parts.size() > 2:
			patch = int(parts[2])
		if parts.size() > 3:
			build = int(parts[3])
		return true
	return false

func save_to_file(filename: String) -> bool:
	var file:= FileAccess.open(filename, FileAccess.WRITE)
	var json:= { "major": major, "minor": minor, "patch": patch, "build": build }
	file.store_line(JSON.stringify(json))
	file.flush()
	file.close()
	return true

func load_from_file(filename: String) -> bool:
	var dict:= Util.load_json_as_dict(filename, func(error): return {})
	if dict:
		if "major" in dict:
			major = int(dict["major"])
		if "minor" in dict:
			minor = int(dict["minor"])
		if "patch" in dict:
			patch = int(dict["patch"])
		if "build" in dict:
			build = int(dict["build"])
		return true
	return false

func equals(v: Version) -> bool:
	return major == v.major and minor == v.minor and patch == v.patch and build == v.build

func less_than(v: Version) -> bool:
	if major < v.major:
		return true
	if major > v.major:
		return false
	if minor < v.minor:
		return true
	if minor > v.minor:
		return false
	if patch < v.patch:
		return true
	if patch > v.patch:
		return false
	return build < v.build

func greater_than(v: Version) -> bool:
	if major > v.major:
		return true
	if major < v.major:
		return false
	if minor > v.minor:
		return true
	if minor < v.minor:
		return false
	if patch > v.patch:
		return true
	if patch < v.patch:
		return false
	return build > v.build
