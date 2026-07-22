extends Node
class_name StateMachine
## A generic, reusable finite state machine (FSM) for Godot.
##
## Add an instance as a child of whatever it controls (a player, an enemy,
## a game-flow manager, a dialogue tree, ...) so its per-frame hooks run
## automatically. Because this is a real [Node] with [code]class_name[/code],
## you can also drag a [code]StateMachine[/code] straight into a scene from
## the "Add Child Node" dialog if you prefer building it visually.
##
## Highlights:
## - Per-state enter / exit / process / physics_process callbacks, and more
##   than one callback per hook if you need it (see [method add_state_hook]).
## - Input-driven transitions, optionally guarded by a condition.
## - "Global" transitions available from ANY state (e.g. an input that kills
##   the player no matter what they're currently doing).
## - Condition-only "auto transitions", checked every frame with no input
##   needed at all (great for AI: "if player in range -> Chase").
## - A state history stack, so you can jump back to whatever was active
##   before ([method go_to_previous_state]).
## - Optional debug logging of every transition ([member debug_mode]) —
##   pairs nicely with a debug console command that prints
##   [method get_current_state_name] for whichever machine you're chasing a bug in.
##
## [b]Example:[/b]
## [codeblock]
## enum States { IDLE, RUN, JUMP, DEAD }
## enum Inputs { MOVE, STOP, JUMP_PRESSED, DIE }
##
## var fsm: StateMachine
##
## func _ready() -> void:
##     fsm = StateMachine.create_machine(States.values(), Inputs.values())
##     fsm.add_state(States.IDLE, _enter_idle)
##     fsm.add_state(States.RUN, _enter_run, Callable(), _process_run)
##     fsm.add_state(States.JUMP, _enter_jump, _exit_jump)
##     fsm.add_state(States.DEAD, _enter_dead)
##
##     fsm.add_transition(States.IDLE, States.RUN, Inputs.MOVE)
##     fsm.add_transition(States.RUN, States.IDLE, Inputs.STOP)
##     fsm.add_transition(States.IDLE, States.JUMP, Inputs.JUMP_PRESSED, Callable(), _is_on_floor)
##     fsm.add_global_transition(States.DEAD, Inputs.DIE) # works from any state
##
##     add_child(fsm)
##     fsm.force_state(States.IDLE) # required once, to kick the machine off
##
## func _is_on_floor() -> bool:
##     return is_on_floor()
## [/codeblock]

## Which per-state lifecycle event a callback added via [method add_state_hook]
## should run on.
enum Hook { ENTER, EXIT, PROCESS, PHYSICS_PROCESS }

## Sentinel passed as the "input" argument of [signal transitioned] (and shown
## in debug logs) when a transition happened automatically via a condition,
## rather than through [method receive_input].
const AUTO_INPUT: int = -1

## Emitted right after entering a state (after its enter hooks have run).
signal state_entered(state: int)
## Emitted right before leaving a state (before its exit hooks have run).
signal state_exited(state: int)
## Emitted whenever a transition completes. [param input] is [constant AUTO_INPUT]
## for condition-based auto transitions.
signal transitioned(from: int, to: int, input: int)

## Optional label for this machine, shown in debug logs. Handy when one scene
## has more than one StateMachine (e.g. a Player fsm and a Weapon fsm).
@export var machine_name: String = "StateMachine"
## When true, every transition (and forced state change) is printed to the
## console. Toggle per-instance in the Inspector, or from a debug console.
@export var debug_mode: bool = false
## How many past states to remember for [method go_to_previous_state]. 0 disables history.
@export var history_size: int = 8

var current_state: State
var machine_states: Dictionary[int, State] = {}
var input_alphabet: Array[int] = []

## Transitions available from ANY state, keyed by input. Checked only if the
## current state itself has no (guard-passing) transition for that input.
var global_transitions: Dictionary[int, Array] = {}
## Condition-only transitions available from ANY state, checked every frame
## regardless of which state is currently active.
var global_auto_transitions: Array[Transition] = []

## Optional data passed into [method receive_input] / [method force_state].
## Readable from inside your hook/action/guard callables as
## [code]machine.current_payload[/code].
var current_payload: Variant = null

## The state that was active immediately before the current one. -1 if none.
var previous_state: int = -1
var state_history: Array[int] = []


#region Setup

func _dummy() -> void:
	pass


func _dummy_delta(_delta: float) -> void:
	pass


func _dummy_guard() -> bool:
	return true


## Creates a machine with every id in [param states] pre-registered (with
## no-op hooks) and [param alphabet] as its valid inputs. Configure hooks and
## transitions afterwards, then call [method force_state] once to start it.
## [codeblock]
## var fsm := StateMachine.create_machine(States.values(), Inputs.values())
## [/codeblock]
static func create_machine(states: Array, alphabet: Array) -> StateMachine:
	var machine := StateMachine.new()
	var typed_alphabet: Array[int] = []
	for i in alphabet:
		typed_alphabet.append(i)
	machine.input_alphabet = typed_alphabet
	for s in states:
		machine.add_state(s)
	return machine


## Registers a state and its lifecycle callbacks (each optional, zero-argument
## except the process hooks which receive delta). Calling this again for the
## same [param state] replaces its hooks — it does NOT remove transitions
## already added for that state. Use [method add_state_hook] to add an extra
## callback without replacing the existing one(s).
## [param display_name] is used only for debug logging; defaults to [code]str(state)[/code].
## [codeblock]
## fsm.add_state(States.JUMP, _enter_jump, _exit_jump)
## [/codeblock]
func add_state(
		state: int,
		enter_func := _dummy,
		exit_func := _dummy,
		process_func := _dummy_delta,
		physics_process_func := _dummy_delta,
		display_name: String = "",
) -> void:
	var s: State = machine_states.get(state)
	if s == null:
		s = State.new()
		s.id = state
		machine_states[state] = s
	s.display_name = display_name if display_name != "" else str(state)
	s.enter_funcs = [enter_func]
	s.exit_funcs = [exit_func]
	s.process_funcs = [process_func]
	s.physics_process_funcs = [physics_process_func]


## Appends an extra callback to one of a state's hooks, without replacing
## whatever is already registered there. Lets several independent systems
## react to the same event (e.g. animation AND sound AND particles on enter).
## [codeblock]
## fsm.add_state_hook(States.JUMP, StateMachine.Hook.ENTER, _play_jump_sfx)
## [/codeblock]
func add_state_hook(state: int, hook: Hook, callable: Callable) -> void:
	if not _validate(state):
		return
	var s := machine_states[state]
	match hook:
		Hook.ENTER:
			s.enter_funcs.append(callable)
		Hook.EXIT:
			s.exit_funcs.append(callable)
		Hook.PROCESS:
			s.process_funcs.append(callable)
		Hook.PHYSICS_PROCESS:
			s.physics_process_funcs.append(callable)


## Adds a transition from one specific state to another on a given input.
## [param guard_func], if provided, must return true for the transition to
## actually happen; if it returns false the input is ignored (as if no
## transition existed). If you add more than one transition for the same
## ([param from], input) pair, they're tried in the order added and the
## first whose guard passes wins.
## [codeblock]
## fsm.add_transition(States.IDLE, States.JUMP, Inputs.JUMP_PRESSED, Callable(), _is_on_floor)
## [/codeblock]
func add_transition(from: int, to: int, input: int, action_func := _dummy, guard_func := _dummy_guard) -> void:
	if not _validate(from) or not _validate(to) or not _validate_input(input):
		return
	var t := Transition.new()
	t.to_state = to
	t.action = action_func
	t.guard = guard_func
	var from_state := machine_states[from]
	if not from_state.transitions.has(input):
		from_state.transitions[input] = []
	from_state.transitions[input].append(t)


## Adds a transition available from ANY state on a given input — e.g. a
## global pause or death input that should work no matter what the machine
## is currently doing. Only checked if the current state has no transition
## of its own for the same input.
func add_global_transition(to: int, input: int, action_func := _dummy, guard_func := _dummy_guard) -> void:
	if not _validate(to) or not _validate_input(input):
		return
	var t := Transition.new()
	t.to_state = to
	t.action = action_func
	t.guard = guard_func
	if not global_transitions.has(input):
		global_transitions[input] = []
	global_transitions[input].append(t)


## Adds a condition-only transition, checked every frame while [param from]
## is the active state — no input required. Useful for AI ("if player in
## range -> Chase") or safety nets ("if health <= 0 -> Dead").
## [param condition_func] must return a bool.
func add_auto_transition(from: int, to: int, condition_func: Callable, action_func := _dummy) -> void:
	if not _validate(from) or not _validate(to):
		return
	var t := Transition.new()
	t.to_state = to
	t.action = action_func
	t.guard = condition_func
	machine_states[from].auto_transitions.append(t)


## Same as [method add_auto_transition] but checked every frame regardless of
## the current state.
func add_global_auto_transition(to: int, condition_func: Callable, action_func := _dummy) -> void:
	if not _validate(to):
		return
	var t := Transition.new()
	t.to_state = to
	t.action = action_func
	t.guard = condition_func
	global_auto_transitions.append(t)

#endregion


#region Runtime

## Feeds an input to the machine. Tries the current state's own transitions
## first, then falls back to global transitions, then does nothing (logging
## a warning in [member debug_mode]) if no valid transition is found.
## [param payload] is optional data, readable from your hooks/guards during
## the transition via [member current_payload].
func receive_input(input: int, payload: Variant = null) -> void:
	if current_state == null:
		push_error("[%s] receive_input called before force_state (no initial state set)" % machine_name)
		return
	if not _validate_input(input):
		return
	current_payload = payload
	var chosen := _pick_valid_transition(current_state.transitions.get(input, []))
	if chosen == null:
		chosen = _pick_valid_transition(global_transitions.get(input, []))
	if chosen == null:
		if debug_mode:
			push_warning("[%s] No valid transition for input %s from state %s" % [machine_name, input, current_state.display_name])
		return
	_do_transition(chosen, input)


## Forces the machine directly into [param state], running exit/enter hooks
## but skipping transition lookup entirely. Use this once to set the initial
## state after setup, and any other time you need to "teleport" the machine
## (cutscenes, save/load, resetting a level).
func force_state(state: int, payload: Variant = null) -> void:
	if not _validate(state):
		return
	current_payload = payload
	if current_state != null:
		_run_hooks(current_state.exit_funcs)
		state_exited.emit(current_state.id)
		_push_history(current_state.id)
	current_state = machine_states[state]
	_run_hooks(current_state.enter_funcs)
	state_entered.emit(current_state.id)
	if debug_mode:
		print("[%s] -> %s (forced)" % [machine_name, current_state.display_name])


## Returns true if [param input] would currently trigger a transition
## (guards included) without actually taking it. Handy for UI, e.g. graying
## out a button that isn't valid right now.
func can_transition(input: int) -> bool:
	if current_state == null or not _validate_input(input):
		return false
	if _pick_valid_transition(current_state.transitions.get(input, [])) != null:
		return true
	return _pick_valid_transition(global_transitions.get(input, [])) != null


## True if the machine's current state is [param state].
func is_in_state(state: int) -> bool:
	return current_state != null and current_state.id == state


## Jumps back to the previously active state. Does nothing if history is
## empty (e.g. right at startup, or if [member history_size] is 0).
func go_to_previous_state(payload: Variant = null) -> void:
	if state_history.is_empty():
		return
	var target: int = state_history.pop_back()
	force_state(target, payload)


func get_current_state() -> int:
	return current_state.id if current_state != null else -1


func get_current_state_name() -> String:
	return current_state.display_name if current_state != null else "<none>"


func has_state(state: int) -> bool:
	return machine_states.has(state)


func _process(delta: float) -> void:
	if current_state == null:
		return
	for h in current_state.process_funcs:
		_call_if_valid(h, [delta])
	_check_auto_transitions()


func _physics_process(delta: float) -> void:
	if current_state == null:
		return
	for h in current_state.physics_process_funcs:
		_call_if_valid(h, [delta])


func _check_auto_transitions() -> void:
	var chosen := _pick_valid_transition(current_state.auto_transitions)
	if chosen == null:
		chosen = _pick_valid_transition(global_auto_transitions)
	if chosen == null:
		return
	_do_transition(chosen, AUTO_INPUT)


func _do_transition(t: Transition, input: int) -> void:
	var to_state := machine_states[t.to_state]
	var from_id := current_state.id
	_run_hooks(current_state.exit_funcs)
	state_exited.emit(from_id)
	_push_history(from_id)
	_call_if_valid(t.action)
	current_state = to_state
	_run_hooks(current_state.enter_funcs)
	state_entered.emit(current_state.id)
	transitioned.emit(from_id, current_state.id, input)
	if debug_mode:
		var input_label := "auto" if input == AUTO_INPUT else str(input)
		print("[%s] %s -> %s (input: %s)" % [machine_name, machine_states[from_id].display_name, current_state.display_name, input_label])


func _run_hooks(hooks: Array[Callable]) -> void:
	for h in hooks:
		_call_if_valid(h)


func _call_if_valid(callable: Callable, args: Array = []) -> void:
	if callable.is_valid():
		callable.callv(args)


func _pick_valid_transition(candidates: Array) -> Transition:
	for c in candidates:
		var t: Transition = c
		if not t.guard.is_valid() or t.guard.call():
			return t
	return null


func _push_history(state_id: int) -> void:
	previous_state = state_id
	if history_size <= 0:
		return
	state_history.append(state_id)
	if state_history.size() > history_size:
		state_history.pop_front()


func _validate(state: int) -> bool:
	if not machine_states.has(state):
		push_error("[%s] Unknown state: %s" % [machine_name, state])
		return false
	return true


func _validate_input(input: int) -> bool:
	if not input_alphabet.has(input):
		push_error("[%s] Input not in alphabet: %s" % [machine_name, input])
		return false
	return true


func _to_string() -> String:
	return "%s<%s>" % [machine_name, get_current_state_name()]

#endregion


#region Inner classes

class State:
	var id: int
	var display_name: String
	var enter_funcs: Array[Callable] = []
	var exit_funcs: Array[Callable] = []
	var process_funcs: Array[Callable] = []
	var physics_process_funcs: Array[Callable] = []
	## input(int) -> Array[Transition]
	var transitions: Dictionary[int, Array] = {}
	var auto_transitions: Array[Transition] = []


class Transition:
	var to_state: int
	var action: Callable
	var guard: Callable

#endregion
