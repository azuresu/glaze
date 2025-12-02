class_name Version extends RefCounted

var major: int
var minor: int
var patch: int
var build: int

func _to_string() -> String:
	return as_string()

func as_string(includes_build:= true) -> String:
	if includes_build:
		return "%s.%s.%s.%s" % [major, minor, patch, build]
	return "%s.%s.%s" % [major, minor, patch]

func save_to_file(filename: String) -> bool:
	var file:= FileAccess.open(filename, FileAccess.WRITE)
	var json:= { "major": major, "minor": minor, "patch": patch, "build": build }
	file.store_line(JSON.stringify(json))
	return true

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

static func parse_string(s: String) -> Version:
	var v = Version.new()
	var parts:= s.split(".")
	if parts.size() > 0:
		v.major = int(parts[0])
	if parts.size() > 1:
		v.minor = int(parts[1])
	if parts.size() > 2:
		v.patch = int(parts[2])
	if parts.size() > 3:
		v.build = int(parts[3])
	return v

static func load_from_file(filename: String) -> Version:
	var file = FileAccess.open(filename, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	var version = Version.new()
	if "major" in json.data:
		version.major = int(json.data["major"])
	if "minor" in json.data:
		version.minor = int(json.data["minor"])
	if "patch" in json.data:
		version.patch = int(json.data["patch"])
	if "build" in json.data:
		version.build = int(json.data["build"])
	return version
