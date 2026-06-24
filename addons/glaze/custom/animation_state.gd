@icon("res://addons/glaze/custom/animation_state.png")
class_name AnimationState extends State

## Format: [animation_library_name/]<animation_name>. Changing it in realtime has no effect.
@export var animation_name: String
## Animation is played backward. Changing it in realtime has no effect.
@export var play_backward: bool
@export var speed_scale:= 1.0

var animation_time: float

var _ana: AnimationNodeAnimation

func get_speed_scale() -> float:
	return speed_scale

func transition(state_name: String, params:= {}) -> void:
	super.transition(state_name, params)
	# Some states can be transitioned to itself when agent requires like melee and roll.
	if machine.current_state and machine.current_state.name == state_name:
		if machine.current_state.reset_when_transition_to_self:
			machine.play_animation(animation_name)

func _process(delta: float) -> void:
	if machine:
		machine.set_animation_condition(name, _has_animation_condition())

func _is_animation_between(begin_time: float, end_time: float, margin:= 0.0) -> bool:
	return animation_time >= begin_time - margin and animation_time <= end_time + margin

func _has_animation_condition() -> bool:
	return machine.current_state == self

func _on_animation_finished() -> void:
	pass
