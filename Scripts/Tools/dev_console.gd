extends CanvasLayer

#TODO There are many nice features to add to a dev console:
# - help command which shows the custom commands and their descriptions
# - printing history and quickly executing old commands, as well as storing commands in a file
# - adding possibility to add nested contexts?
# - time controls, pause timescale etc
# - reload
# - find and tree inspection
# - basic function chaining stuff like && | etc (don't know if chaining is easily possible)


## FEATURES
## History with arrow keys
## Simple autocomplete with tab
## Customization
## Helpful commands to navigate through your nodes/code
## 
## Uses expressions so many gdscript expressions are supported
## You don't need to export every function you want to be able to use from the console
## to expose functions you just pass along the node with add_context, and the dev console will
## handle exposing functions, variables and signals.
## 
## Contexts are here to make it easier to navigate through your nodes and commands
## you can list contexts with 'ls c' and access them with 'cd mycontext', you can then call 'ls'
## again to see al available functions, variables and signals


# --- Inspector-facing (must stay public) ---
@export var prompt_symbol: String = "~ "
@export var prompt_symbol_color: Color = Color.AQUA
@export var error_color: Color = Color.RED
@export var keyword_color: Color = Color.html("#ff7085")
@export var symbol_color: Color = Color.html("#abc9ff")
@export var func_color: Color = Color.html("#57b3ff")
@export var context_color: Color = Color.html("#ffbf66")
@export var background_color: Color = Color.html("#03030377")

@export var hide_private: bool = true
@export var pause_when_shown: bool = true

enum TYPE { PROPERTY, METHOD, SIGNAL, CONTEXT }

# --- Node references ---
@onready var _text_input: LineEdit = %TextInput
@onready var _console = %Console
@onready var _prompt = %prompt
var _symbol: String = ""

# --- Command history ---
var _history: Array[String] = []
var _history_index: int = -1

# --- Autocomplete state ---
# Where in the list of possible matches we are
var _autocomplete_index: int = 0
# All entries that are viable for autocomplete
var _autocomplete_choices: Array = []
# Track if the last input was related to autocomplete
var _last_input_was_autocomplete: bool = false
# Cached matches so the search isn't repeated while Tabbing through options
var _prev_autocomplete_matches: Array = []

# --- Contexts ---
var _contexts: Dictionary[String, Node] = {
	"console": self,
}
var _current_context: String = "console"

var _is_open := false


func _ready() -> void:
	$MarginContainer/ColorRect.color = background_color
	process_mode = Node.PROCESS_MODE_ALWAYS
	_symbol = "[color=%s]%s[/color]" % [prompt_symbol_color.to_html(), prompt_symbol]

	_text_input.grab_focus()
	set_context("console")
	hide()


func toggle() -> void:
	if _is_open:
		close()
	else:
		open()


func open() -> void:
	_is_open = true
	show()

	if pause_when_shown:
		get_tree().paused = true

	_text_input.grab_focus()


func close() -> void:
	_is_open = false

	if pause_when_shown:
		get_tree().paused = false

	hide()


func add_context(name: String, node: Node) -> void:
	if node == null:
		push_error("trying to add a null node as context")
		return
	_contexts[name] = node

	node.tree_exiting.connect(
		func():
			if _contexts.get(name) == node:
				_contexts.erase(name)
	)


func set_context(name: String) -> void:
	if name in _contexts:
		_current_context = name

		if _current_context == null:
			var error_msg = name + " context it's no longer available, it may have been queue free'd"
			push_error(error_msg)
			print_line(error_msg, error_color)
			return

		_autocomplete_choices = _load_script(_current_context)
		_prompt.text = "[color=%s][%s] [/color][color=%s]%s [/color]" % [
			context_color.to_html(),
			_current_context,
			prompt_symbol_color.to_html(),
			prompt_symbol,
		]


# Reads a context's script for its methods, variables and signals
func _load_script(context: String) -> Array:
	var choices: Array = _get_from_script(TYPE.SIGNAL, context)
	choices.append_array(_get_from_script(TYPE.PROPERTY, context))
	choices.append_array(_get_from_script(TYPE.METHOD, context))
	return choices


func _get_from_script(type: TYPE, context: String = _current_context, name_only := true) -> Array:
	var node: Node = _contexts.get(context)
	if node == null:
		return []

	var script: Script = node.get_script()
	if script == null:
		return []

	var result: Array
	match type:
		TYPE.PROPERTY:
			result = script.get_script_property_list()
		TYPE.METHOD:
			result = script.get_script_method_list()
		TYPE.SIGNAL:
			result = script.get_script_signal_list()
		_:
			return []

	if hide_private:
		result = result.filter(func(n): return not n.name.begins_with("_"))

	if name_only:
		result = result.map(func(n): return n.name)
		result.sort()
	else:
		result.sort_custom(func(a, b): return a.name < b.name)

	return result


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("_dev_console_toggle"):
		toggle()
		get_viewport().set_input_as_handled()
		return

	if not visible:
		return

	var was_autocomplete := false

	if event.is_action_pressed("_dev_console_autocomplete"):
		_autocomplete()
		was_autocomplete = true
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("_dev_console_submit"):
		_submit()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("_dev_console_prev"):
		_navigate_history(1)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("_dev_console_next"):
		_navigate_history(-1)
		get_viewport().set_input_as_handled()

	if event is InputEventKey and event.pressed:
		_last_input_was_autocomplete = was_autocomplete


func _autocomplete() -> void:
	var matches: Array = []
	var match_string := _text_input.text

	# Reuse the last result set if the user is stepping through options
	if _last_input_was_autocomplete:
		matches = _prev_autocomplete_matches
	# Offer everything if there's nothing to filter on
	elif match_string.is_empty():
		matches = _autocomplete_choices.duplicate()
	else:
		for choice in _autocomplete_choices:
			if choice.begins_with(match_string):
				matches.append(choice)

	_prev_autocomplete_matches = matches

	if matches.is_empty():
		return

	if _last_input_was_autocomplete:
		_autocomplete_index = wrapi(_autocomplete_index + 1, 0, matches.size())
	else:
		_autocomplete_index = 0

	_text_input.text = matches[_autocomplete_index]
	_text_input.caret_column = _text_input.text.length()


func _submit() -> void:
	var cmd := _text_input.text.strip_edges()

	_text_input.clear()
	_history_index = -1
	_reset_autocomplete()
	# Focus can be lost if a command touches the scene tree
	_text_input.call_deferred("grab_focus")

	if cmd.is_empty():
		return
	if _history.is_empty() or _history[0] != cmd:
		_history.push_front(cmd)

	run_command(cmd)


func _navigate_history(direction: int) -> void:
	_reset_autocomplete()
	if _history.is_empty():
		return
	# -1 means "back to an empty line"
	_history_index = clampi(_history_index + direction, -1, _history.size() - 1)
	_text_input.text = "" if _history_index == -1 else _history[_history_index]
	_text_input.caret_column = _text_input.text.length()


func _reset_autocomplete() -> void:
	_autocomplete_index = 0
	_prev_autocomplete_matches.clear()
	_last_input_was_autocomplete = false


func run_command(cmd: String) -> void:
	print_line(_prompt.text + cmd)

	if _run_custom_command(cmd):
		return

	var expression := Expression.new()
	var parse_error := expression.parse(cmd)
	if parse_error != OK:
		print_line(expression.get_error_text(), error_color)
		return

	var context: Node = _contexts.get(_current_context)
	var result = expression.execute([], context, true)

	if expression.has_execute_failed():
		print_line(expression.get_error_text(), error_color)
		return

	if result != null:
		print_line(str(result))

#region CUSTOM COMMANDS

func _run_custom_command(cmd: String) -> bool:
	match cmd:
		"clear":
			_console.clear()
			return true
	match cmd.substr(0, 2):
		"ls":
			match cmd.substr(3, -1):
				"m":
					list(TYPE.METHOD)
				"v":
					list(TYPE.PROPERTY)
				"c":
					list(TYPE.CONTEXT)
				"s":
					list(TYPE.SIGNAL)
				"":
					list(TYPE.SIGNAL)
					list(TYPE.PROPERTY)
					list(TYPE.METHOD)
					list(TYPE.CONTEXT)
		"cd":
			set_context(cmd.substr(3, -1))
		_:
			return false
	return true


func print_line(text: String, color = null) -> void:
	if color != null:
		_console.append_text("\n[color=%s]%s[/color]" % [color.to_html(), text])
	else:
		_console.append_text("\n" + text)


func list(type: TYPE) -> void:
	match type:
		TYPE.PROPERTY:
			for property in _get_from_script(TYPE.PROPERTY, _current_context, false):
				print_line(
					"[color=%s]var [/color][color=%s]%s[/color]" % [
						keyword_color.to_html(),
						symbol_color.to_html(),
						property["name"],
					],
				)
		TYPE.METHOD:
			for method in _get_from_script(TYPE.METHOD, _current_context, false):
				print_line(
					"[color=%s]func [/color][color=%s]%s[/color](%s)" % [
						keyword_color.to_html(),
						func_color.to_html(),
						method["name"],
						_format_args(method["args"]),
					],
				)
		TYPE.SIGNAL:
			for sig in _get_from_script(TYPE.SIGNAL, _current_context, false):
				print_line(
					"[color=%s]signal [/color][color=%s]%s[/color](%s)" % [
						keyword_color.to_html(),
						symbol_color.to_html(),
						sig["name"],
						_format_args(sig["args"]),
					],
				)
		TYPE.CONTEXT:
			for context in _contexts:
				print_line("[color=%s]context [/color]%s" % [context_color.to_html(), context])


func _format_args(args: Array) -> String:
	return ", ".join(args.map(func(a): return a["name"]))

#endregion
