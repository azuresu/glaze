# Project Glaze
Godot Library by AZurEsu. It works as a plugin.

阿朱苏的戈多库。这是一个插件。

## Scripts

### Glaze

An auto-loaded global singleton added by plugin. It provides many useful functions.

插件添加的全局单例，提供了许多有用的方法。

Some important functions as following:

以下是一些较为重要的方法：

| Function | Description |
| --- | --- |
| new_scene | Creates a new scene instance from cached packed scene. |
| rand_option | Returns an option randomly picked from an array. Chance of picking depends on the weights if specified. |
| load_json_as_array | Load JSON file and make sure it is an array. Built-in types can be parsed optionally. |
| load_json_as_dict | Load JSON file and make sure it is a dictionary. Built-in types can be parsed optionally. |

#### More about Glaze.new_scene()

This function provides useful features for you to create new instance of scenes. At minimum, you got:
	
该方法为创建场景实例提供了更多的有用特性，至少有一下这些：

- Cache: Glaze automatically caches all packed scenes so you don't have to store them manually;

缓存：Glaze自动缓存所有的序列化场景，你不再需要自己做缓存；

- Simplicity: You can create new scene instance and add it into parent with single-line script.

简单：你可以用一行代码创建场景实例并添加进父场景；

At maximum, you get following advantages if you define scenes in scene data file:

如果配置了场景数据文件，你还可以获得以下优点：

- Scene can be referred with short name which is immune to directory change (you have to change scene_path in the data file of course but no change required in script);

使用较短的名称来指定场景，这样就不需要在修改目录结构时改动代码（但仍旧需要在场景数据文件中修改scene_path）；

- Data can be centralized into data files so you can use your preferred text editor to make the change;

数据可以被集中在文件中，让你方便地使用任何你喜欢的文本编辑器来编辑；

- Data can be inherited from another to reduce duplication therefore mistakes of inconsistent data;

数据可以继承，以此减少重复数据和错误；

- Plugin has Scene Data Viewer enabled in Godot IDE bottom panel which is a great way to view and search data.

插件在集成开发环境的下方增加了场景数据查看器，可以方便查看并搜索。

### Version

A simple class represents version in: major.minor.patch.build.

一个简单的类用来描述版本号。

### Parser
A class provides parsing and formating on various types when working with JSON. User can customize parsers and add them into Glaze.

解析器类提供额外的解析和格式化JSON数据能力。用户可以定制自己的解析器加入Glaze中。

## Custom nodes

### Evaluate

A unidirectional binding which updates property automatically with configured source. After being added into parent, name it with the property name you want to set.

赋值节点提供了从数据源到目标属性的单向数据绑定。加入场景树后，请以需要绑定的属性名称来命名该节点。

### Interval

A timer calls a func on the parent node periodically. After being added into parent, name it with the func name you want to call.

一个定时器节点，用来周期性调用某个方法。加入场景树后，请以需要调用的函数名来命名该节点。

### StateMachine and State

A simple implementation of state machine.

一个简单的状态机实现。

## Setup

### Copy addons
Copy directory 'addons' to your project.

### Use symlink
Run following command with administrator privilege:

`mklink /D <project_dir>\addons\glaze <glaze_dir>\addons\glaze`

*Note if you clone the plugin repository and use symlink in your project, changes will be made to some plugin scenes as they are marked @tool.
Therefore you will have uncommited changes in Git.*

### Add configuration file (optional but highly recommended)

Once installed plugin, you may create a JSON file under your project directory and named it 'glaze.json'.
This is the configuration this plugin reads whenever game starts.

| Property | Description | Default value |
| --- | --- | --- |
| log_level | Log level | "INFO" |
| log_rich_text | Log message in rich text (different colors for different levels) | true |
| scene_data_allow_builtin_types | Allow built-in types configured in scene data file | true |
| scene_data_files | A list of scene data files | [] |

## Scene data
You can configure any property accessible to the scene. However there are some pre-defined properties will be used by plugin:
| Property | Description |
| --- | --- |
| scene_path | A full path to the tscn file |
| derived_scene | A scene from which all properties will be inherited to this scene |
| scene_name | Note you don't need to config this in data file, instead the scene name will be set to this property if it exists in scene script. The name will also be set to meta so you may retrieve it even the property does not exist. |
