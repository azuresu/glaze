@tool
@icon("res://addons/glaze/custom/press.png")
## Name this button with the func name you want to call when pressed.
class_name Press extends Button

## Owner of the function. It will be default to scene owner if not specified.
@export var func_owner: Node

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
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
