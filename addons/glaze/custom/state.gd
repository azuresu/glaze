@icon("res://addons/glaze/custom/state.png")
## Put this node under StateMachine node.
class_name State extends Node

@export var reset_when_transition_to_self:= false

var machine: StateMachine:
	get: return get_parent()

var update_time: float

func transition(state_name: String, params:= {}) -> void:
	machine.set_current_state(state_name, params)

## Called when state enters as current.
func _enter() -> void:
	pass

## Called when state exits as current.
func _exit() -> void:
	pass

## Called when state is current in each frame.
func _update(delta: float) -> void:
	pass

## Called when state is current in each physics frame.
func _physics_update(delta: float) -> void:
	pass
