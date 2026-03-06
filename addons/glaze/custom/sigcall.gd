@tool
@icon("res://addons/glaze/custom/sigcall.png")
## Name this node with the signal name in the parent node. It only supports signals with no parameters.
class_name Sigcall extends Node

## Owner of the function. It will be default to scene owner if not specified.
@export var func_owner: Node
## Name of the function which will be called when signal is emitted.
@export var func_name: String

func _ready() -> void:
	if get_parent().has_signal(name):
		get_parent()[name].connect(_emit)
	else:
		Glaze.log_error("Signal: %s not found on %s", name, get_parent())

func _emit() -> void:
	var fo:= func_owner
	if not fo:
		fo = owner
	if fo:
		if fo.has_method(func_name):
			fo.call(func_name)
		else:
			Glaze.log_error("Func name: %s not found on owner:%s", func_name, fo)
	else:
		Glaze.log_error("Func owner not found: %s", self)
