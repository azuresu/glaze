## A customizable post-import script utilizes regular expression to locate nodes and process.
class_name CustomImport extends EditorScenePostImport

## The scene which is imported.
var scene: Node

## The node which is being processed currently.
var node: Node

## Set to true to skip further processing on the current node.
var skip: bool

var _callback: Dictionary[RegEx, Callable]

func add_callback(regex: String, callback: Callable) -> bool:
	var re = RegEx.new()
	if re.compile(regex) == OK:
		_callback[re] = callback
		return true
	return false

## Set up callbacks in this func.
func _customize() -> void:
	pass

func _post_import(scene: Node) -> Object:
	self.scene = scene
	_customize()
	print("Post-import: %s" % scene.name)
	_iterate(scene)
	return scene

func _iterate(node: Node) -> void:
	var children:= node.get_children().duplicate()
	for re in _callback:
		if re.search(node.name):
			self.node = node
			skip = false
			_callback[re].call()
			if skip:
				return
	for ch in children:
		_iterate(ch)
