class_name StateMachine

var current_state: State
var machine_states: Dictionary[int, State] = { }
var input_alphabet: Array[int]

# Points of improvement:
# - Adding a debugger
# - Adding multiple function calls per state?
# - Adding args for state functions?


#Dummy callable when no callable is set
func _dummy():
	pass


func receive_input(input: int):
	assert(input_alphabet.has(input))
	var transition = current_state.transitions.get(input)
	var new_state: State = transition[0]
	var transition_func: Callable = transition[1]
	transition_func.call()
	new_state.state_func.call()
	current_state = new_state


func force_state(state: int):
	current_state = machine_states.get(state)
	current_state.state_func.call()


## A full state machine can be specified like so
## [codeblock]
## enum States {S1, S2, S3}
## enum Inputs {I1, I2, I3}
## var states = [
## [States.S1, lambda_func],
## [States.S2],
## [States.S3, lambda_func2 ]
## ]
## var transitions = [
## [States.S1, States.S2, Inputs.I1, lambda_func1],
## [States.S2, States.S3, Inputs.I2],
## [States.S2, States.S3, Inputs.I3, lambda_func3]
## ]
## var state_machine = StateMachine.create_machine(states, transitions, Inputs.values(), States.S1)
## [/codeblock]
## This will create a state machine with the initial State S1, and the States enum
static func create_machine(
		states: Array,
		transitions: Array,
		alphabet: Array[int],
		init_state: int,
) -> StateMachine:
	var machine = StateMachine.new()
	var is_enum = states.size() > 0 and typeof(states[0]) == TYPE_INT

	machine.input_alphabet = alphabet
	if is_enum:
		machine.add_states_from_enum(states, init_state)
	else:
		machine.add_states_from_array(states, init_state)

	machine.add_transitions_from_array(transitions)
	return machine


## States can be added through an array like so:
## [codeblock]
## enum States {S1, S2, S3}
## var states = [ [States.S1, lambda_func] [States.S2] [States.S3, lambda_func2 ]
## mystate_machine.add_states_from_enum(States.values(), States.S1)
## [/codeblock]
## This will create a state machine with the initial State S1, and the States enum
func add_states_from_array(states: Array, initial_state: int):
	for state_data: Array in states:
		if state_data.size() == 2:
			#(state, Callable)
			add_state(state_data[0], state_data[1])
		elif state_data.size() == 1:
			add_state(state_data[0])
		else:
			assert(false) #Invalid array input
	current_state = machine_states[initial_state]


## States can be added through an enum like so:
## [codeblock]
## enum States {S1, S2, S3}
## mystate_machine.add_states_from_enum(States.values(), States.S1)
## [/codeblock]
## This will create a state machine with the initial State S1, and the States enum
func add_states_from_enum(states: Array[int], initial_state: int):
	for key in states:
		add_state(key)
	current_state = machine_states[initial_state]


## Transitions can be added through an array like so:
## [codeblock]
## var transitions = [
## [States.S1, States.S2, Input.S3, lambda_func]
## [States.S3, States.S4, Input.S1, lambda_func2]
## [States.S1, States.S2, Input.S3, lambda_func]
## [States.S5, States.S6, Input.S1 ]
## [States.S6, States.S5, Input.S2 ]
##]
## mystate_machine.add_transitions_from_array(States.S1, States.S2, Input.I1, lambda_func)
## [/codeblock]
## This will add a transition from the state S1 to S2 when the state-machine receives I1 as input.
## lambda_func will be called on transition.
## [color=yellow]Warning: lamba_func should take no args
func add_transitions_from_array(transitions: Array):
	for tdata: Array in transitions:
		if tdata.size() == 3:
			add_transition(tdata[0], tdata[1], tdata[2])
		elif tdata.size() == 4:
			add_transition(tdata[0], tdata[1], tdata[2], tdata[3])
		else:
			assert(false) #invalid array input


## Transitions can be defined and added the following way:
## [codeblock]
## enum States {S1, S2, S3}
## enum Input { I1, I2, I2}
## mystate_machine.add_transition(States.S1, States.S2, Input.I1, lambda_func)
## [/codeblock]
## This will add a transition from the state S1 to S2 when the state-machine receives I1 as input.
## lambda_func will be called on transition.
## [color=yellow]Warning: lamba_func should take no args
func add_transition(from: int, to: int, input: int, trans_func := _dummy):
	assert(machine_states.has(from) && machine_states.has(to) && input_alphabet.has(input))
	var from_state = machine_states.get(from)
	var to_state = machine_states.get(to)
	from_state.transitions.set(input, [to_state, trans_func])


## States can be defined and added the following way:
## [codeblock]
##     enum States {S1, S2, S3}
##     mystate_machine.add_transition(States.S1, lambda_func)
## [/codeblock]
## This will add a transition from the state S1 to S2 when the state-machine receives I1 as input.
## lambda_func will be called when entering this state.
## [color=yellow]Warning: lamba_func should take no args
func add_state(state: int, state_func := _dummy):
	machine_states.set(state, State.new_state(state_func, { }))


class State:
	var state_func: Callable
	var transitions: Dictionary = { } # [input(int) ,[State, Callable]]


	static func new_state(init_func, init_transitions) -> State:
		var state = State.new()
		state.state_func = init_func
		state.transitions = init_transitions
		return state

"""
The idea of having
State func-> whenever we enter this, call the func
Transition func -> whenever this transition happens, call the func, 
"""
