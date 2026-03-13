@tool
@icon("res://addons/glaze/custom/press.png")
## Name this node with the func name you want to call.
class_name Press extends Node

## Owner of the function. It will be default to scene owner if not specified.
@export var func_owner: Node
## Name of the signal which is emitted to call the func. It is default to "pressed" as this node is used for button mainly.
@export var signal_name:= "pressed"

func _ready() -> void:
	if get_parent().has_signal(signal_name):
		get_parent()[signal_name].connect(_press)
	else:
		Glaze.log_error("Signal: %s not found on %s", signal_name, get_parent())

func _press() -> void:
	var fo:= func_owner
	if not fo:
		fo = owner
	if fo:
		if fo.has_method(name):
			fo.call(name)
		else:
			Glaze.log_error("Func name: %s not found on owner:%s", name, fo)
	else:
		Glaze.log_error("Func owner not found: %s", self)
