@tool
extends Node

@export var source: Node
@export var source_var: String
@export var updates_per_second:= 60
@export var update_ratio:= 1.0

var _update_delta: float

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var ups:= updates_per_second * update_ratio
	if ups > 0:
		var _timeout:= 1.0 / ups
		_update_delta += delta
		if _update_delta >= _timeout:
			_eval()
			_update_delta -= _timeout

func _eval() -> void:
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
