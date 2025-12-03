@tool
@icon("res://addons/glaze/custom/state_machine.png")
class_name StateMachine extends Node

signal state_entered(state: State)
signal state_exited(state: State)

var current_state: State
var states: Dictionary

func set_current_state(state_name: String, params:= {}) -> void:
	call_deferred("_set_current_state", state_name, params)

func _ready() -> void:
	for ch in get_children():
		if ch is State:
			ch.machine = self
			states[ch.name] = ch
	if states:
		current_state = states.values()[0]
	else:
		Glaze.log_warn("No state found in state machine: %s", self)

func _process(delta: float) -> void:
	if current_state:
		current_state.update_time += delta
		current_state._update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_update(delta)

func _set_current_state(state_name: String, params:= {}) -> void:
	if state_name in states:
		if current_state:
			current_state._exit()
			state_exited.emit(current_state)
		current_state = states[state_name]
		for k in params:
			if k in current_state:
				current_state[k] = params[k]
		current_state.update_time = 0
		current_state._enter()
		state_entered.emit(current_state)
	else:
		Glaze.log_error("No such state: %s in state machine: %s", state_name, self)
