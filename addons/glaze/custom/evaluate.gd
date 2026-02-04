@tool
@icon("res://addons/glaze/custom/evaluate.png")
## Name this node with the property name in the parent node.
class_name Evaluate extends Node

## Source of evaluation. Fall back to owner if not specified.
@export var source: Node
## Name of the variable in the source.
@export var source_var: String
## Enable bidirectional binding to set value back the source variable.
@export var bidirectional: bool

var _source_value

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
		if source_var in s:
			var val = s[source_var]
			if not _source_value == val:
				_source_value = val
				get_parent()[name] = val
			elif bidirectional:
				var v = get_parent()[name]
				if not v == val:
					s[source_var] = v
		else:
			Glaze.log_error("No such variable: %s on source: %s", source_var, s)
	else:
		Glaze.log_error("No such property: %s on %s", name, get_parent())
