@tool
@icon("res://addons/glaze/custom/state_machine.png")
## StateMachine node contains one or more State nodes.
class_name StateMachine extends Node

signal state_entered(state: State)
signal state_exited(state: State)

var current_state: State
var states: Dictionary

func set_current_state(state_name: String, params:= {}) -> void:
	_set_current_state.call_deferred(state_name, params)

func _ready() -> void:
	for ch in get_children():
		if ch is State:
			ch.machine = self
			states[ch.name] = ch
		else:
			Glaze.log_warn("Non-state node: %s is under state machine: %s", ch, self)
	if states:
		current_state = states.values()[0]
		Glaze.log_debug("State machine: %s has initial state: %s", self, current_state)
	else:
		Glaze.log_warn("No state found in state machine: %s", self)

func _process(delta: float) -> void:
	if current_state:
		current_state.update_time += delta
		current_state._update(delta)
		Glaze.log_debug("State machine: %s updated state: %s", self, current_state)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_update(delta)
		Glaze.log_debug("State machine: %s physics-updated state: %s", self, current_state)

func _set_current_state(state_name: String, params:= {}) -> void:
	if state_name in states:
		if current_state:
			current_state._exit()
			state_exited.emit(current_state)
			Glaze.log_debug("Current state exited: %s" % current_state)
		current_state = states[state_name]
		for k in params:
			if k in current_state:
				current_state[k] = params[k]
		current_state.update_time = 0
		current_state._enter()
		state_entered.emit(current_state)
		Glaze.log_debug("Current state entered: %s" % current_state)
	else:
		Glaze.log_error("No such state: %s in state machine: %s", state_name, self)
