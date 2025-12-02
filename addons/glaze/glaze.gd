extends Node
## A toolkit class provides many useful functions to make developing game in GDScript easier (hopefully).
## This class will be auto-loaded as a Global once plugin is enabled.

const _CONFIG_FILE:= "res://glaze.json"
const _LOG_LEVEL_NAMES:= ["DEBUG", "INFO ", "WARN ", "ERROR", "FATAL"]
const _LOG_LEVEL_COLORS:= ["gray", "white", "yellow", "red", "purple"]

enum LogLevel {
	DEBUG, INFO, WARN, ERROR, FATAL
}

var log_level:= LogLevel.INFO
var log_rich_text:= true

var scene_data_files:= ["res://scenes.json"]
var scene_data: Dictionary
var scene_data_allow_builtin_types:= true

var _builtin_parsers: Array[Parser]
var _packed_scenes: Dictionary[String, Resource]

## Creates a new scene and adds it to parent when provided.
## The new-created scene is an instance of cached packed scene which is defined in scene file.
func new_scene(scene_name: String, parent: Node = null) -> Node:
	if not scene_name in _packed_scenes:
		var scene_path: String
		if scene_name in scene_data:
			var data: Dictionary = scene_data[scene_name]
			if "scene_path" in data:
				scene_path = data["scene_path"]
		if not scene_path:
			scene_path = scene_name
			log_warn("Scene path is not defined with scene name: %s" % scene_name)
		var s:= load(scene_path)
		if s:
			_packed_scenes[scene_name] = s
		else:
			log_error("Scene not found: %s" % scene_path)
	if scene_name in _packed_scenes:
		var scene: Node = _packed_scenes[scene_name].instantiate()
		# Copy data into scene.
		if scene_name in scene_data:
			var data: Dictionary = scene_data[scene_name]
			for k in scene_data[scene_name]:
				if k in scene:
					scene[k] = data[k]
		scene.set_meta("scene_name", scene_name)
		if "scene_name" in scene:
			scene["scene_name"] = scene_name
		# Add to parent.
		if parent:
			parent.add_child(scene)
		return scene
	return null

## Returns the first argument if it is a valid instance, otherwise returns the second argument.
func validate(obj: Variant, dft: Variant = null) -> Variant:
	return obj if is_instance_valid(obj) else dft

## Returns an element from options randomly depends on the weights if specified.
func rand_option(options: Array, weights:= []) -> Variant:
	var sum:= 0.0
	var chances:= []
	for i in range(options.size()):
		sum += float(weights[i]) if i < weights.size() else 1.0
		chances.append(sum)
	var f = randf()
	for i in range(chances.size()):
		if f < chances[i] / sum:
			return options[i]
	return null

## Returns a value which is the addition of base and offset but also limited in range (from - inclusive, to - exclusive).
func cycle_range(base: int, offset: int, from: int, to: int) -> int:
	var r:= to - from
	var v = base + offset - from
	while v < 0: # Why am I so stupid?
		v += r
	return v % r + from

## Frees children from parent.
func free_children(parent: Node, filter:= func(ch): return true) -> void:
	for ch in parent.get_children():
		if filter.call(ch):
			parent.remove_child(ch)
			ch.queue_free()

## Returns wether log level is DEBUG.
func log_debug_enabled() -> bool:
	return log_level == LogLevel.DEBUG

## Logs a debug-level message.
func log_debug(message: String) -> void:
	return log_msg(LogLevel.DEBUG, message)

## Logs an info-level message.
func log_info(message: String) -> void:
	return log_msg(LogLevel.INFO, message)

## Logs a warn-level message.
func log_warn(message: String) -> void:
	return log_msg(LogLevel.WARN, message)

## Logs an error-level message.
func log_error(message: String) -> void:
	return log_msg(LogLevel.ERROR, message)

## Logs a fatal-level message.
func log_fatal(message: String) -> void:
	return log_msg(LogLevel.FATAL, message)

## Logs a message with specified level.
func log_msg(level: LogLevel, message: String) -> void:
	if level >= log_level:
		var time = Time.get_datetime_dict_from_system()
		var time_str:= "%04d-%02d-%02d %02d:%02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute, time.second]
		if log_rich_text:
			print_rich("[color=%s]%s | %s | %s[/color]" % [_LOG_LEVEL_COLORS[level], time_str, _LOG_LEVEL_NAMES[level], message])
		else:
			print("%s | %s | %s" % [time_str, _LOG_LEVEL_NAMES[level], message])

## Adds built-in parser.
## Added parser is always inserted to the first position in parser queue therefore it has chance to override default parsers.
func add_builtin_parser(parser: Parser) -> void:
	_builtin_parsers.insert(0, parser)

## Removes built-in parser.
func remove_builtin_parser(parser: Parser) -> void:
	_builtin_parsers.erase(parser)

## Parses given argument with built-in parsers.
func parse_builtin_types(value: Variant) -> Variant:
	if value is Array:
		for i in value.size():
			value[i] = parse_builtin_types(value[i])
	elif value is Dictionary:
		for k in value:
			value[k] = parse_builtin_types(value[k])
	elif value is String:
		for p in _builtin_parsers:
			if p.can_parse(value):
				return p.parse(value)
	return value

## Formats given argument with built-in parsers.
func format_builtin_types(value: Variant) -> Variant:
	if value is Array:
		for i in value.size():
			value[i] = format_builtin_types(value[i])
	elif value is Dictionary:
		for k in value:
			value[k] = format_builtin_types(value[k])
	for p in _builtin_parsers:
		if p.can_format(value):
			return p.format(value)
	return value

## Loads JSON as dictionary from file.
func load_json_as_dict(filename: String, parse_builtin_types:= false) -> Dictionary:
	var json = JSON.new()
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var error = json.parse(file.get_as_text())
		if not error:
			if json.data is Dictionary:
				if parse_builtin_types:
					parse_builtin_types(json.data)
				return json.data
			else:
				log_error("JSON is not a dictionary in json file: %s" % filename)
		else:
			log_error("Error in parsing json file: %s" % filename)
	else:
		log_error("File not found: %s" % filename)
	return {}

## Loads JSON as array from file.
func load_json_as_array(filename: String, parse_builtin_types:= false) -> Array:
	var json = JSON.new()
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var error = json.parse(file.get_as_text())
		if not error:
			if json.data is Array:
				if parse_builtin_types:
					parse_builtin_types(json.data)
				return json.data
			else:
				log_error("JSON is not an array in json file: %s" % filename)
		else:
			log_error("Error in parsing json file: %s" % filename)
	else:
		log_error("File not found: %s" % filename)
	return []

func _ready() -> void:

	_builtin_parsers.append_array(Parser.builtin_parsers)

	if FileAccess.file_exists(_CONFIG_FILE):
		var config:= load_json_as_dict(_CONFIG_FILE)
		if "log_level" in config:
			var log_level:= LogLevel.keys().find(config["log_level"])
			if log_level >= 0:
				self.log_level = log_level
			else:
				log_error("Invalid log level: %s" % config["log_level"])

		if "log_rich_text" in config:
			log_rich_text = config["log_rich_text"] as bool

		if "scene_data_allow_builtin_types" in config:
			scene_data_allow_builtin_types = config["scene_data_allow_builtin_types"] as bool

		if "scene_data_files" in config:
			scene_data_files = config["scene_data_files"] as Array

		for file in scene_data_files:
			log_debug("Loading scene data file: %s" % file)
			var data:= load_json_as_dict(file, scene_data_allow_builtin_types)
			for scene_name in data:
				if scene_name in scene_data:
					scene_data[scene_name].merge(data[scene_name], true)
					log_debug("Scene data merged: %s" % scene_name)
				else:
					scene_data[scene_name] = data[scene_name]
					log_debug("Scene data added: %s" % scene_name)
		for scene_name in scene_data:
			_merge_derived_data(scene_name)
	else:
		log_warn("Missing configuration file: %s" % _CONFIG_FILE)

func _merge_derived_data(scene_name: String, derived_chain:= {}) -> Dictionary:
	if scene_name in scene_data:
		var data:= scene_data[scene_name] as Dictionary
		if "derived_scene" in data:
			var derived_scene_name:= data["derived_scene"] as String
			log_debug("Found scene: %s derived from scene: %s" % [scene_name, derived_scene_name])
			if derived_scene_name in derived_chain:
				log_error("Looping derived scene: %s" % derived_scene_name)
			else:
				derived_chain[derived_scene_name] = 1
				var derived_data:= _merge_derived_data(data["derived_scene"], derived_chain)
				for k in derived_data:
					if not k in data:
						data[k] = derived_data[k]
			data.erase("derived_scene")
		return data
	log_error("Missing derived scene: %s" % scene_name)
	return {}
