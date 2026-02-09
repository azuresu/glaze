@icon("res://addons/glaze/custom/quick_button.png")
extends Button

@export var func_owner: Node
@export var func_params: Array

func _on_pressed() -> void:
	var fo:= func_owner
	if not fo:
		fo = owner
	if fo.has_method(name):
		fo.callv(name, func_params)
	else:
		Glaze.log_error("Func owner not found: %s", self)
