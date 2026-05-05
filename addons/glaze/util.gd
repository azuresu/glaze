## A utilities class has no context of project.
## It is NOT expected to be used outside of Glaze plugin.
class_name Util extends Object

## Loads JSON as dictionary from file.
static func load_json_as_dict(filename: String, error_handler: Callable) -> Dictionary:
	var json = JSON.new()
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var error = json.parse(file.get_as_text())
		if not error:
			if json.data is Dictionary:
				return json.data
			else:
				return error_handler.call("JSON is not a dictionary in json file: %s" % filename)
		else:
			return error_handler.call("Error in parsing json file: %s" % filename)
	else:
		return error_handler.call("File not found: %s" % filename)

## Loads JSON as array from file.
static func load_json_as_array(filename: String, error_handler: Callable) -> Array:
	var json = JSON.new()
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var error = json.parse(file.get_as_text())
		if not error:
			if json.data is Array:
				return json.data
			else:
				return error_handler.call("JSON is not an array in json file: %s" % filename)
		else:
			return error_handler.call("Error in parsing json file: %s" % filename)
	else:
		return error_handler.call("File not found: %s" % filename)
