@icon("res://addons/glaze/custom/animation_state_machine.png")
# A state machine automatically wires up all animation states into specified AnimationTree.
class_name AnimationStateMachine extends StateMachine

@export var animation_tree: AnimationTree

# Cache conditions to improve performance (a lot!)
var _animation_conditions: Dictionary[String, bool]
var _animation_time_scale:= 1.0

func set_animation_condition(param_name: String, param_value: bool) -> void:
	if not param_name in _animation_conditions or not _animation_conditions[param_name] == param_value:
		_animation_conditions[param_name] = param_value
		animation_tree.set("parameters/StateMachine/conditions/%s" % param_name, param_value)

func play_animation(animation_name: String) -> void:
	animation_tree.get("parameters/StateMachine/playback").start(animation_name)

func _ready() -> void:
	super._ready()
	state_entered.connect(_on_state_entered)
	state_exited.connect(_on_state_exited)
	_fix_tree()

func _process(delta: float) -> void:
	super._process(delta)
	if current_state is AnimationState:
		var anim_ss: float = current_state.get_speed_scale()
		current_state.animation_time += delta * anim_ss
		_set_animation_time_scale(anim_ss)

func _fix_tree() -> void:
	if animation_tree:
		var blend_tree:= AnimationNodeBlendTree.new()
		var state_machine:= AnimationNodeStateMachine.new()
		var time_scale:= AnimationNodeTimeScale.new()
		blend_tree.add_node("StateMachine", state_machine)
		blend_tree.add_node("TimeScale", time_scale)
		blend_tree.connect_node("TimeScale", 0, "StateMachine")
		blend_tree.connect_node("output", 0, "TimeScale")
		var ap = animation_tree.get_node(animation_tree.anim_player)
		if ap is AnimationPlayer:
			_fix_animations(state_machine, ap)
			_fix_transitions(state_machine)
		else:
			Glaze.log_error("Animation player not found in golem animation tree: %s", animation_tree)
		animation_tree.tree_root = blend_tree
		animation_tree.animation_finished.connect(_on_animation_finished)
	else:
		Glaze.log_error("No animation tree set for animation state machine: %s", self)

func _fix_animations(sm: AnimationNodeStateMachine, ap: AnimationPlayer) -> void:
	for state_name in states:
		if state_name == "Start" or state_name == "End":
			Glaze.log_warn("Animation state name is not allowed: %s" % state_name)
			continue
		var s = states[state_name]
		if s is AnimationState and not sm.has_node(state_name):
			var ana:= AnimationNodeAnimation.new()
			var anim_name: String = s.animation_name
			if not anim_name:
				anim_name = s.name
			var anim_lib:= ""
			var i = anim_name.find("/")
			if i >= 0:
				anim_lib = anim_name.substr(0, i)
				anim_name = anim_name.substr(i + 1)
			if anim_lib:
				if ap.has_animation_library(anim_lib):
					var lib:= ap.get_animation_library(anim_lib)
					if not lib.has_animation(anim_name):
						Glaze.log_error("Animation: %s not found in animation library %s used by state: %s", anim_name, anim_lib, state_name)
				else:
					Glaze.log_error("Animation library %s not found used by state: %s", anim_lib, state_name)
			else:
				if not ap.has_animation(anim_name):
					Glaze.log_error("Animation %s not found used by state: %s", anim_name, state_name)
			ana.animation = ("%s/%s" % [anim_lib, anim_name]) if anim_lib else anim_name
			ana.play_mode = AnimationNodeAnimation.PLAY_MODE_BACKWARD if s.play_backward else AnimationNodeAnimation.PLAY_MODE_FORWARD
			sm.add_node(state_name, ana)
			s._ana = ana

func _fix_transitions(sm: AnimationNodeStateMachine) -> void:
	var node_list: Array[StringName] = sm.get_node_list()
	for i in node_list.size():
		if sm.get_node(node_list[i]) is AnimationNodeAnimation:
			for j in node_list.size():
				if sm.get_node(node_list[j]) is AnimationNodeAnimation and not i == j and not _has_transition(sm, node_list[i], node_list[j]):
					var trans:= AnimationNodeStateMachineTransition.new()
					trans.xfade_time = 0.2 # Maybe this should be configurable in animation state.
					trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
					trans.advance_condition = str(node_list[j])
					sm.add_transition(node_list[i], node_list[j], trans)
	# Add transition from start to current immediately.
	if current_state and not _has_transition(sm, &"Start", current_state.name):
		var trans:= AnimationNodeStateMachineTransition.new()
		trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		sm.add_transition(&"Start", current_state.name, trans)

func _has_transition(sm: AnimationNodeStateMachine, from: StringName, to: StringName) -> bool:
	for i in sm.get_transition_count():
		if sm.get_transition_from(i) == from and sm.get_transition_to(i) == to:
			return true
	return false

func _on_animation_finished(animation_name: String) -> void:
	if current_state is AnimationState and animation_name == current_state.animation_name:
		current_state._on_animation_finished()

func _on_state_entered(state: State) -> void:
	if state is AnimationState:
		state.animation_time = 0
		_set_animation_time_scale(state.get_speed_scale())

func _on_state_exited(state: State) -> void:
	if state is AnimationState:
		_set_animation_time_scale(1.0)

func _set_animation_time_scale(time_scale: float) -> void:
	if not _animation_time_scale == time_scale:
		_animation_time_scale = time_scale
		animation_tree.set("parameters/TimeScale/scale", time_scale)
