# Project Glaze
Godot library by azuresu. It works as a plugin.

## Functions
### Glaze
An auto-loaded global singleton added by plugin. It provides many useful functions.
Some important functions:
| Function | Description |
| --- | --- |
| new_scene | Creates a new scene instance from cached packed scene which is configured in scene data file. |
| rand_option | Returns an option randomly picked from an array. Chance of picking depends on the weights if specified. |
| load_json_as_array | Load JSON file and make sure it is an array. Built-in types can be parsed optionally. |
| load_json_as_dict | Load JSON file and make sure it is a dictionary. Built-in types can be parsed optionally. |

### Version
A simple class represents version in: major.minor.patch.build.

### Parser
A class provides parsing and formating on various types when working with JSON.

## Setup
Once installed plugin, you may create a JSON file under your project directory and named it 'glaze.json'.
This is the configuration this plugin reads whenever game starts.

| Property | Description | Default value |
| --- | --- | --- |
| log_level | Log level | "INFO" |
| log_rich_text | Log message in rich text (different colors for different levels) | true |
| scene_data_allow_builtin_types | Allow built-in types configured in scene data file | true |
| scene_data_files | A list of scene data files | ["res://scenes.json"] |

## Scene data
You can configure any property accessible to the scene. However there are some pre-defined properties will be used by plugin:
| Property | Description |
| --- | --- |
| scene_path | A full path to the tscn file |
| derived_scene | A scene from which all properties will be inherited to this scene |
| scene_name | Note you don't need to config this in data file, instead the scene name will be set to this property if it exists in scene script. The name will also be set to meta so you may retrieve it even the property does not exist. |
