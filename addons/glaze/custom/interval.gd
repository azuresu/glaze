@tool
@icon("res://addons/glaze/custom/interval.png")
## Name this node with the func name it will called periodically in the parent.
class_name Interval extends Node

## How many times the func will be called in a second.
@export var updates_per_second:= 60.0
## The actual calls per second is updates_per_second * update_ratio.
@export var update_ratio:= 1.0
## start at random timing to avoid a large amount of simultaneous burst.
@export var random_start:= true

var _update_delta: float

func _ready() -> void:
	var ups:= updates_per_second * update_ratio
	if ups > 0 and random_start:
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
