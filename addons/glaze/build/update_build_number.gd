#!/usr/bin/env -S godot -s
extends SceneTree

const _CONFIG_FILE:= "res://glaze.json"

func _init() -> void:
	var config:= Util.load_json_as_dict(_CONFIG_FILE, func(error):
		print(error)
		return {})
	if config:
		if "version_file" in config:
			var version_file = config.get("version_file")
			var version:= Version.new()
			version.load_from_file(version_file)
			if version:
				version.build += 1
				version.save_to_file(version_file)
				print("Updated version %s into %s" % [version, version_file])
				quit(0)
			else:
				print("Invalid version file: %s" % version_file)
				quit(1)
		else:
			print("No version_file in config: %s" % _CONFIG_FILE)
			quit(1)
	else:
		quit(1)
