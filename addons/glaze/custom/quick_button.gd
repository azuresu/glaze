@icon("res://addons/glaze/custom/quick_button.png")
class_name QuickButton extends Button

@export var func_owner: Node
@export var func_name: String
@export var func_params: Array

func _on_pressed() -> void:
	var fo:= func_owner
	if not fo:
		fo = owner
	if fo:
		var fn:= func_name
		if not fn:
			fn = name
		if fo.has_method(fn):
			fo.callv(fn, func_params)
		else:
			Glaze.log_error("Func name: %s not found on owner:%s", fn, fo)
	else:
		Glaze.log_error("Func owner not found: %s", self)
