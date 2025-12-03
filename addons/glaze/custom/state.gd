@tool
@icon("res://addons/glaze/custom/state.png")
class_name State extends Node

var machine: StateMachine
var update_time: float

func _transition(state_name: String, params:= {}) -> void:
	machine.set_current_state(state_name, params)

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass

func _physics_update(delta: float) -> void:
	pass
