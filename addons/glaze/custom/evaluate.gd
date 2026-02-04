@tool
@icon("res://addons/glaze/custom/evaluate.png")
## Name this node with the property name in the parent node.
class_name Evaluate extends Node

## Source of evaluation. Fall back to owner if not specified.
@export var source: Node
## Name of the variable or function in the source.
@export var source_var: String

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var s:= source
	if not s:
		s = owner

	if not s:
		Glaze.log_error("Source not found when evaluating: %s", name)
	elif not source_var:
		Glaze.log_error("Source variable found when evaluating: %s", name)
	elif name in get_parent():
		if s.has_method(source_var):
			get_parent()[name] = s.call(source_var)
		elif source_var in s:
			get_parent()[name] = s[source_var]
		else:
			Glaze.log_error("No such variable: %s on source: %s", source_var, s)
	else:
		Glaze.log_error("No such property: %s on %s", name, get_parent())
