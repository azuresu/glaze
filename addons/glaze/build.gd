#!/usr/bin/env -S godot -s
## A build script can be run directly in headless mode. For example:
## %GODOT% --headless -s addons\glaze\build.gd -- <command> [arguments]
extends SceneTree

var _command: String
var _argument_name: String
var _arguments: Dictionary[String, Array]

func _init() -> void:
	var arg_type:= ""
	for arg in OS.get_cmdline_user_args():
		if _command:
			if arg.begins_with("-"):
				if _argument_name:
					if not _argument_name in _arguments:
						_arguments[_argument_name] = [""]
				_argument_name = arg.substr(1)
			else:
				if _argument_name:
					if not _argument_name in _arguments:
						_arguments[_argument_name] = []
					_arguments[_argument_name].append(arg)
				else:
					_warn("No argument name for %s. Value ignored." % arg)
		else:
			_command = arg

	if _argument_name and not _argument_name in _arguments:
		_arguments[_argument_name] = [""]

	if _command:
		if has_method(_command):
			quit(call(_command))
		else:
			_error("Invalid command: %s" % _command)
			quit(1)
	else:
		_error("Missing command.")
		quit(1)
	# Append a blank line before end.
	print()

func has_argument(argument_name: String) -> bool:
	return argument_name in _arguments

func get_argument_size(argument_name: String) -> int:
	if argument_name in _arguments:
		return _arguments[argument_name].size()
	return 0

func get_argument(argument_name: String, index:= 0) -> String:
	if argument_name in _arguments:
		return _arguments[argument_name][index]
	return ""

## update_build_number -version_file <path> [-update_project_file]
func update_build_number() -> int:
	if has_argument("version_file"):
		var version_file = get_argument("version_file")
		var version:= Version.new()
		if version.load_from_file(version_file):
			var old = version.copy()
			version.build += 1
			_info("Increased version from %s to %s" % [old, version])
			version.save_to_file(version_file)
			_info("Updated version to %s in %s" % [version, version_file])
			if has_argument("update_project_file"):
				var proj_file:= "project.godot"
				var proj_config = ConfigFile.new()
				var error = proj_config.load(proj_file)
				if error == OK:
					proj_config.set_value("application", "config/version", version.format())
					proj_config.save(proj_file)
					_info("Updated version to %s in %s" % [version, proj_file])
				else:
					_error("Failed to load project file: %s" % proj_file)
					return 1
			return 0
		else:
			_error("Invalid version file: %s" % version_file)
	else:
		_error("No version_file in arguments.")
	return 1

func _info(msg: String) -> void:
	print_rich("BUILD: [color=white]%s[/color]" % msg)

func _error(msg: String) -> void:
	print_rich("BUILD: [color=red]%s[/color]" % msg)

func _warn(msg: String) -> void:
	print_rich("BUILD: [color=yellow]%s[/color]" % msg)
