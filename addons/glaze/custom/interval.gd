@tool
extends Node

@export var updates_per_second:= 60

var _update_delta: float

func _ready() -> void:
	if updates_per_second > 0:
		# Make an even distribution of updating in case of a large amount of simultaneous start.
		_update_delta = randf_range(0, 1.0 / updates_per_second)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if updates_per_second > 0:
		var _timeout:= 1.0 / updates_per_second
		_update_delta += delta
		if _update_delta >= _timeout:
			if get_parent().has_method(name):
				get_parent().call(name, _timeout)
			else:
				Glaze.log_error("No such function: %s on %s", name, get_parent())
			_update_delta -= _timeout
