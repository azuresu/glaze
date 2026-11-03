@tool
@icon("res://addons/glaze/custom/animation_state_machine.png")
# A state machine wires up all animation states into specified AnimationTree.
class_name AnimationStateMachine extends StateMachine

@export var animation_tree: AnimationTree
@export var editor_node_gap:= Vector2i(200, 200)
@export_tool_button("Build Tree Root") var build_button = _build_tree_root

# Cache conditions to improve performance (a lot!)
var _animation_conditions: Dictionary[String, bool]
var _animation_time_scale:= 1.0

func get_animation_states() -> Array[AnimationState]:
	var r: Array[AnimationState]
	r.assign(get_children().filter(func(ch): return ch is AnimationState))
	return r

func set_animation_condition(param_name: String, param_value: bool) -> void:
	if not param_name in _animation_conditions or not _animation_conditions[param_name] == param_value:
		_animation_conditions[param_name] = param_value
		animation_tree.set("parameters/StateMachine/conditions/%s" % param_name, param_value)

func play_animation(animation_name: String) -> void:
	animation_tree.get("parameters/StateMachine/playback").start(animation_name)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super._ready()
	state_entered.connect(_on_state_entered)
	state_exited.connect(_on_state_exited)
	animation_tree.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super._process(delta)
	if current_state is AnimationState:
		var anim_ss: float = current_state.get_speed_scale()
		current_state.animation_time += delta * anim_ss
		_set_animation_time_scale(anim_ss)

func _build_tree_root() -> void:
	print("Building animation tree root...")
	if animation_tree:
		animation_tree.tree_root = null
		var blend_tree:= AnimationNodeBlendTree.new()
		var state_machine:= AnimationNodeStateMachine.new()
		var time_scale:= AnimationNodeTimeScale.new()
		blend_tree.add_node("StateMachine", state_machine)
		blend_tree.add_node("TimeScale", time_scale)
		blend_tree.set_node_position("StateMachine", Vector2(-2 * editor_node_gap.x, 0))
		blend_tree.set_node_position("TimeScale", Vector2(-0.5 * editor_node_gap.x, 0))
		blend_tree.connect_node("TimeScale", 0, "StateMachine")
		blend_tree.connect_node("output", 0, "TimeScale")
		var ap = animation_tree.get_node(animation_tree.anim_player)
		if ap is AnimationPlayer:
			var first_state:= _build_animations(state_machine, ap)
			_build_transitions(state_machine, first_state)
			print("Building animation tree root completed.")
		else:
			printerr("Animation player not found in animation tree: %s" % animation_tree)
		animation_tree.tree_root = blend_tree
	else:
		printerr("No animation tree set for animation state machine: %s", self)

func _build_animations(sm: AnimationNodeStateMachine, ap: AnimationPlayer) -> AnimationState:
	print("Building animation nodes...")
	var states: Dictionary[String, AnimationState]
	for ch in get_children():
		if ch is AnimationState:
			states[ch.name] = ch
	var cols:= maxi(1, int(sqrt(states.size())))
	var pos: Vector2i
	for state_name in states:
		print("Building animation node: %s" % state_name)
		if state_name == &"Start" or state_name == &"End":
			printerr("Animation state name is not allowed: %s" % state_name)
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
						printerr("Animation: %s not found in animation library %s used by state: %s" % [anim_name, anim_lib, state_name])
				else:
					printerr("Animation library: %s not found used by state: %s" % [anim_lib, state_name])
			else:
				if not ap.has_animation(anim_name):
					printerr("Animation %s not found used by state: %s" % [anim_name, state_name])
			ana.animation = ("%s/%s" % [anim_lib, anim_name]) if anim_lib else anim_name
			ana.play_mode = AnimationNodeAnimation.PLAY_MODE_BACKWARD if s.play_backward else AnimationNodeAnimation.PLAY_MODE_FORWARD
			sm.add_node(state_name, ana)
			sm.set_node_position(state_name, editor_node_gap * pos)
			pos.x += 1
			if pos.x >= cols:
				pos.x = 0
				pos.y += 1
	return states.values()[0] if states else null

func _build_transitions(sm: AnimationNodeStateMachine, first_state: AnimationState) -> void:
	print("Building animation transitions...")
	var node_list: Array[StringName] = sm.get_node_list()
	for i in node_list.size():
		if sm.get_node(node_list[i]) is AnimationNodeAnimation:
			if node_list[i] == &"Start" or node_list[i] == &"End":
				continue
			for j in node_list.size():
				if node_list[j] == &"Start" or node_list[j] == &"End":
					continue
				if sm.get_node(node_list[j]) is AnimationNodeAnimation and not i == j and not _has_transition(sm, node_list[i], node_list[j]):
					var trans:= AnimationNodeStateMachineTransition.new()
					trans.xfade_time = 0.2 # Maybe this should be configurable in animation state.
					trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
					trans.advance_condition = str(node_list[j])
					sm.add_transition(node_list[i], node_list[j], trans)
					print("Build transition from %s to to %s" % [node_list[i], node_list[j]])
	if first_state:
		var trans:= AnimationNodeStateMachineTransition.new()
		trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		sm.add_transition(&"Start", first_state.name, trans)

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
