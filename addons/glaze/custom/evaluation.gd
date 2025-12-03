@tool
extends Node

@export var source: Node
@export var source_var: String

func _process(delta: float) -> void:
	if source and source_var and name in get_parent():
		if source.has_method(source_var):
			get_parent()[name] = source.call(source_var)
		elif source_var in source:
			get_parent()[name] = source[source_var]
