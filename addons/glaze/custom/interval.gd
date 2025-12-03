@tool
extends Node

@export var updates_per_second:= 60
@export var update_ratio:= 1.0

var _update_delta: float

func _ready() -> void:
	var ups:= updates_per_second * update_ratio
	if ups > 0:
		# Make an even distribution of updating in case of a large amount of simultaneous start.
		_update_delta = randf_range(0, 1.0 / ups)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var ups:= updates_per_second * update_ratio
	if ups > 0:
		var _timeout:= 1.0 / ups
		_update_delta += delta
		if _update_delta >= _timeout:
			if get_parent().has_method(name):
				get_parent().call(name, _timeout)
			else:
				Glaze.log_error("No such function: %s on %s", name, get_parent())
			_update_delta -= _timeout
