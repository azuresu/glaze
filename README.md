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
	
该方法为创建场景实例提供了更多的有用特性，至少有以下这些：

- Cache: Glaze automatically caches all packed scenes so you don't have to store them manually;

- 缓存：Glaze自动缓存所有的序列化场景，你不再需要自己做缓存；

- Simplicity: You can create new scene instance and add it into parent with single-line script.

- 简单：你可以用一行代码创建场景实例并添加进父场景；

For example, the following three lines:

例如，以下的三行代码：

```
var packed_scene = load("res://scenes/object.tscn")
var new_object = packed_scene.instantiate()
parent_node.add_child(new_object)
```

Can be reduced to one line:

可以被缩减为一行：

```
Glaze.new_scene("res://scenes/object.tscn", parent_node)
```

At maximum, you get following advantages if you define scenes in scene data file:

如果配置了场景数据文件，你还可以获得以下优点：

- Scene can be referred with short name which is immune to directory change (you have to change scene_path in the data file of course but no change required in script);

- 使用较短的名称来指定场景，这样就不需要在修改目录结构时改动代码（但仍旧需要在场景数据文件中修改scene_path）；

- Data can be centralized into data files so you can use your preferred text editor to make the change;

- 数据可以被集中在文件中，让你方便地使用任何你喜欢的文本编辑器来编辑；

- Data can be inherited from another to reduce duplication therefore mistakes of inconsistent data;

- 数据可以继承，以此减少重复数据和错误；

- Plugin has Scene Data Viewer enabled in Godot IDE bottom panel which is a great way to view and search data.

- 插件在集成开发环境的下方增加了场景数据查看器，可以方便查看并搜索。

### Version

A simple class represents version in: major.minor.patch.build.

一个简单的类用来描述版本号。

### Parser
A class provides parsing and formating on various types when working with JSON. User can customize parsers and add them into Glaze.

解析器类提供额外的解析和格式化JSON数据能力。用户可以定制自己的解析器加入Glaze中。

### CustomImport
A customizable post-import script utilizes regular expression to locate nodes and process.

一个可定制的导入脚本，该脚本使用正则表达式来过滤节点并处理。

A simple example to use this script to hide all nodes which have name ends with *_invis*:

一个简单的例子，隐藏所有名字以 *_invis* 结尾的节点：

```
@tool
extends CustomImport

func _customize() -> void:
	add_callback("_invis\\z", _set_invis) # Returns false if regex failed to compile.

func _set_invis() -> void:
	if node is Node3D:
		node.visible = false
```

## Custom nodes

### Evaluate

A unidirectional binding which updates property automatically with configured source. After being added into parent, name it with the property name you want to set.

赋值节点提供了从数据源到目标属性的单向数据绑定。加入场景树后，请以需要绑定的属性名称来命名该节点。

For example, we have a scene:

例如，有如下的场景：

```
UI (source: ui.gds)
  - Label
    - text (source var: label_text)
    - visible (source var: label_visible)
```

In ui.gds, we define two members to provide binding data:

在ui.gds代码里，定义两个变量来提供被绑定的数据：

```
var label_text: String:
	get: return "something"
var label_visible: bool:
	get: return true
```

As a result, the label text and visibility is controlled by binding data in runtime.

如此一来，在运行时标签的文字和可见性就由被绑定的数据来控制。

### Interval

A timer calls a func on the parent node periodically. After being added into parent, name it with the func name you want to call.

一个间隔器节点，用来周期性调用某个方法。加入场景树后，请以需要调用的函数名来命名该节点。

Comparing with Godot bulti-in timer, it has advantages:
	
和戈多自带的Timer相比，该节点有以下优点：

- Stable interval when it is small;

- 稳定的间隔时间，即使这个时间很短；

- Easy to config: name it with called func;

- 方便使用：直接以被调用的函数名称来命名；

- Flexiable interval config with ratio in runtime;

- 通过速率参数可灵活控制运行期的间隔时间；

- Random start-up to reduce clog when large amount of Intervals added into scene tree (for example when game is loaded).

- 随机的启动时间用来在大量间隔器同时加入场景树时减少卡顿（比如读取游戏存盘时）。

### StateMachine and State

A simple implementation of state machine. Just another lovely wheel :)

一个简单的状态机实现。就另一个可爱的轮子罢了：）

## Tools in Godot editor

Some tools are added into Godot editor once plugin is enabled.

一旦插件启用后，一些工具界面会被加入Godot编辑器。

### Scene data viewer

A new tab called 'GLAZE scenes' will be available on bottom area. It lists all scene data.

一个新的标签'GLAZE scenes'会在底部出现。所有的场景数据都会被列在这里。

### Translation viewer

A new tab called 'GLAZE translation' will be available on bottom area. It lists all translations. You can also update all translation CSV files in one click here.

一个新的标签'GLAZE translation'会在底部出现。所有的翻译数据都会被列在这里。你也可以在这里一键更新所有的翻译CSV文件。

## Setup

There are two ways to enable the plugin: copy addons or use symlink.

有两种方法可以启用插件：拷贝addons目录或者使用符号链接。

### Copy addons

Copy directory 'addons' to your project.

拷贝目录'addons'到你的项目里。

### Use symlink

Run following command with administrator privilege:

使用管理员权限运行以下命令：

`mklink /D <project_dir>\addons\glaze <glaze_dir>\addons\glaze`

*Note if you clone the plugin repository and use symlink in your project, changes will be made to some plugin scenes as they are marked @tool.
Therefore you will have uncommited changes in Git repository.*

*要注意的是如果你的插件目录是直接从插件代码库克隆而来，在使用过程中可能会有修改被应用于插件内的部分标记为@tool的场景，请保持这些本地修改而不必提交至Git仓库。*

### Add configuration file (optional but highly recommended)

Once plugin is installed and enabled, you may create a JSON file under your project directory and named it 'glaze.json'.
This is the configuration this plugin reads whenever game starts. So you need to export this file as well.

一旦插件安装完成并启用，你可以在你的项目根目录下创建一个名为'glaze.json'的文件，这是插件的总配置文件，会在游戏启动时读取。所以这个文件也需要被导出在运行包里。

| Property | Description | Default value |
| --- | --- | --- |
| log_level | Log level | "INFO" |
| log_rich_text | Log message in rich text (different colors for different levels) | true |
| scene_data_allow_builtin_types | Allow built-in types configured in scene data file | true |
| scene_data_files | A list of scene data files | [] |
| translation_languages | A list of translation languages, like en, zh, etc. | [] |
| translation_files | A list of translation CSV files | [] |

## Scene data
You can configure any property accessible to the scene. However there are some pre-defined properties will be used by plugin:
| Property | Description |
| --- | --- |
| scene_path | A full path to the tscn file |
| derived_scene | A scene from which all properties will be inherited to this scene |
| scene_name | Note you don't need to config this in data file, instead the scene name will be set to this property if it exists in scene script. The name will also be set to meta so you may retrieve it even the property does not exist. |
