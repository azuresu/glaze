# Project Glaze
阿朱苏的戈多库。这是一个插件。

## Scripts

### Glaze
插件添加的全局单例，提供了许多有用的方法。

以下是一些较为重要的方法：

| Function | Description |
| --- | --- |
| new_scene | Creates a new scene instance from cached packed scene. |
| rand_option | Returns an option randomly picked from an array. Chance of picking depends on the weights if specified. |
| load_json_as_array | Load JSON file and make sure it is an array. Built-in types can be parsed optionally. |
| load_json_as_dict | Load JSON file and make sure it is a dictionary. Built-in types can be parsed optionally. |

#### More about Glaze.new_scene()
该方法为创建场景实例提供了更多的有用特性，至少有以下这些：

- 缓存：Glaze自动缓存所有的序列化场景，你不再需要自己做缓存；

- 简单：你可以用一行代码创建场景实例并添加进父场景；

例如，以下的三行代码：

```
var packed_scene = load("res://scenes/object.tscn")
var new_object = packed_scene.instantiate()
parent_node.add_child(new_object)
```

可以被缩减为一行：

```
Glaze.new_scene("res://scenes/object.tscn", parent_node)
```

如果配置了场景数据文件，你还可以获得以下优点：

- 使用较短的名称来指定场景，这样就不需要在修改目录结构时改动代码（但仍旧需要在场景数据文件中修改scene_path）；

- 数据可以被集中在文件中，让你方便地使用任何你喜欢的文本编辑器来编辑；

- 数据可以继承，以此减少重复数据和错误；

- 插件在集成开发环境的下方增加了场景数据查看器，可以方便查看并搜索。

### Version
一个简单的类用来描述版本号。

### Parser
解析器类提供额外的解析和格式化JSON数据能力。用户可以定制自己的解析器加入Glaze中。

### CustomImport
一个可定制的导入脚本，该脚本使用正则表达式来过滤节点并处理。

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

### Build
一个可以直接以无GUI方式运行的构建脚本。

你可以在自己的shell脚本里用如下的方式调用：

```
%GODOT% --headless -s addons\glaze\build.gd -- <command> [arguments]
```

命令列表：

```update_build_number -version_file <path> [-update_project_file]```

将版本文件中的版本构建号加1。同时可以把最新的版本号更新进项目文件（可选）。

## Custom nodes

### Evaluate
赋值节点提供了从数据源到目标属性的双向数据绑定。加入场景树后，请以需要绑定的属性名称来命名该节点。

例如，有如下的场景：

```
UI (source: ui.gds)
  - Label
	- text (source var: label_text)
	- visible (source var: label_visible)
```

在ui.gds代码里，定义两个变量来提供被绑定的数据：

```
var label_text: String:
	get: return "something"
var label_visible: bool:
	get: return true
```

如此一来，在运行时标签的文字和可见性就由被绑定的数据来控制。

当你需要把数据从目标属性写回数据源，请打开bidirectional选项。超容易的吧！

如果没有指定数据源，默认使用场景owner。

### Interval
一个间隔器节点，用来周期性调用某个方法。加入场景树后，请以需要调用的函数名来命名该节点。

和戈多自带的Timer相比，该节点有以下优点：

- 稳定的间隔时间，即使这个时间很短；

- 方便使用：直接以被调用的函数名称来命名；

- 通过速率参数可灵活控制运行期的间隔时间；

- 随机的启动时间用来在大量间隔器同时加入场景树时减少卡顿（比如读取游戏存盘时）。

### StateMachine and State
一个简单的状态机实现。就另一个可爱的轮子罢了：）

## Tools in Godot editor
一旦插件启用后，一些工具界面会被加入Godot编辑器。

### Scene data viewer
一个新的标签'GLAZE scenes'会在底部出现。所有的场景数据都会被列在这里。

![Screenshot](docs/glaze_scenes_tab.png)

### Translation viewer
一个新的标签'GLAZE translation'会在底部出现。所有的翻译数据都会被列在这里。你也可以在这里一键更新所有的翻译CSV文件。

![Screenshot](docs/glaze_translation_tab.png)

### Search everywhere
连续按SHIFT键两次，一个标题为“Search everywhere”的窗口会弹出，允许用户通过文件名搜索项目文件夹下的所有文件。

![Screenshot](docs/glaze_search_everywhere.png)

## Setup
有两种方法可以启用插件：拷贝addons目录或者使用符号链接。

### Copy addons
拷贝目录'addons'到你的项目里。

### Use symlink
使用管理员权限运行以下命令：

`mklink /D <project_dir>\addons\glaze <glaze_dir>\addons\glaze`

*要注意的是如果你的插件目录是直接从插件代码库克隆而来，在使用过程中可能会有修改被应用于插件内的部分标记为@tool的场景，请保持这些本地修改而不必提交至Git仓库。*

### Add configuration file (optional but highly recommended)
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
你可以在场景配置文件里添加任何属性。但是下列名称的属性应保留给插件使用。

| Property | Description |
| --- | --- |
| scene_path | A full path to the tscn file |
| derived_scene | A scene from which all properties will be inherited to this scene |
| scene_name | Note you don't need to config this in data file, instead the scene name will be set to this property if it exists in scene script. The name will also be set to meta so you may retrieve it even the property does not exist. |
