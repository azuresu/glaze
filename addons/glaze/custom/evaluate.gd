@tool
@icon("res://addons/glaze/custom/evaluate.png")
## Name this node with the property name in the parent node.
class_name Evaluate extends Node

## Source of evaluation
@export var source: Node
## Name of the variable or function in the source.
@export var source_var: String

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if source and source_var:
		if name in get_parent():
			if source.has_method(source_var):
				get_parent()[name] = source.call(source_var)
			elif source_var in source:
				get_parent()[name] = source[source_var]
			else:
				Glaze.log_error("No such variable: %s on source: %s", source_var, source)
		else:
			Glaze.log_error("No such property: %s on %s", name, get_parent())
