extends Node
## Simple Autoload Manager, to handle UI Instantiation, switching and data connection.[br][br]
##
## 1. Create you UI tscn, attach the [Interface] template to it's root node.[br]
## 2. You can override different [b]callbacks[/b] shown in the template and write your code.[br]
## 3. Add a new entry in the [enum UIManager.UI] enum
##    and [member UIManager.UI_PATHS] dictionary in UIManager.gd[br]
## 4. You can finally show any UI with:
## [codeblock]
## UIManager.invoke_ui(UI.MyUI) # to instantiate a single one
## UIManager.switch_ui(UI.MyOtherUI, DisplayMode.HIDE) # to show a UI and hide other UIs below them
## # There's also helper functions:
## show()
## hide()
## remove()
## show_all()
## hide_all()
## [/codeblock]

## All known UI keys
enum UI { NONE, MAIN_MENU, SETTINGS }
## Mapping between a UI key and its tscn
const UI_PATHS = {
	UI.MAIN_MENU: "uid://i8c14jrjxiq8",
	UI.SETTINGS: "uid://crb7lkmq7wr6",
}

## This enum specifies how to switch to another UI.[br][br]
##
## ON_TOP:[br]
##     Current UI stays visible underneath the newUI.[br][br]
##
## HIDE:[br]
##     Other UIs are hidden, and the new UI is put on top.
##     When the new UI is hidden/removed, the previous UI comes back.[br][br]
##
## REMOVE:[br]
##     Other UIs are removed, and the new UI is put on top.
##     When the new UI is hidden/removed, the previous UI comes back
##     (it is re-created if needed).[br][br]
enum DisplayMode { ON_TOP, HIDE, REMOVE }

signal interface_shown(key: UI)
signal interface_hidden(key: UI)
signal interface_created(key: UI)
signal interface_removed(key: UI)

var active_interfaces: Dictionary[UIManager.UI, Interface] = { }

## The UI navigation stack.
## Last element = currently active/top UI.
var ui_stack: Array[UIManager.UI] = []

## The root on which UI tscns will be added
## This hast to be set by a script after initialization of main tscn
var root_node: CanvasLayer

#region OPENING

## Invokes an UI.[br]
## If it is active but hidden it shows it.[br]
## Else it loads it and instantiates it.[br]
## It pushes it to the top of the UI Stack
func invoke_ui(key: UIManager.UI):
	if not UI_PATHS.has(key):
		push_error("interface key not registered: %s" % key)
		return

	# Register as the top of the navigation stack (no duplicates).
	_remove_from_stack(key)
	ui_stack.append(key)

	if active_interfaces.has(key):
		show(key)
		return

	if root_node == null:
		push_error("UIManager.root_node is not set")
		return

	var scene := load(UI_PATHS[key]) as PackedScene
	if scene == null:
		push_error("could not load interface scene: %s" % key)
		return

	var interface := scene.instantiate() as Interface
	interface.key = key

	interface_created.emit(key)

	active_interfaces[key] = interface
	root_node.add_child(interface)


## Shows an UI, with invoke_ui,
## affects all other active UIs, depending on display_mode
func switch_ui(
		key: UIManager.UI,
		display_mode: DisplayMode = DisplayMode.ON_TOP,
):
	var others: Array = active_interfaces.keys().filter(func(k): return k != key)

	match display_mode:
		DisplayMode.HIDE:
			for k in others:
				active_interfaces[k].hide()
				interface_hidden.emit(k)
		DisplayMode.REMOVE:
			for k in others:
				_free_interface(k)

	# Registers on the stack, then shows or creates it.
	invoke_ui(key)

#endregion

#region SHOW / HIDE / REMOVE

## Shows a UI.
## If it isn't active, invoke it.
func show(key: UIManager.UI):
	if not active_interfaces.has(key):
		invoke_ui(key)
		return

	var interface := active_interfaces[key]

	interface.show()
	interface.on_interface_shown()
	interface_shown.emit(key)


## Hides a UI.
##
## If it was the top UI, the previous UI in the stack is shown again.
func hide(key: UIManager.UI):
	if not active_interfaces.has(key):
		return

	var interface := active_interfaces[key]

	interface.hide()
	interface_hidden.emit(key)

	var was_top := get_top_ui() == key
	_remove_from_stack(key)

	# If we just hid the active UI, restore whatever was underneath it.
	if was_top:
		_show_previous_ui()


## Removes a UI.
##
## If it was the top UI, the previous UI in the stack is shown again.
func remove(key: UIManager.UI):
	if not active_interfaces.has(key):
		push_error("Trying to remove inactive interface")
		return

	var was_top := get_top_ui() == key

	_remove_from_stack(key)
	_free_interface(key)

	# Restore the previous UI.
	if was_top:
		_show_previous_ui()


## Hides all UIs.
##
## Unlike hide(), this deliberately does NOT restore previous UIs.
func hide_all():
	for key in active_interfaces.keys():
		active_interfaces[key].hide()
		interface_hidden.emit(key)

	ui_stack.clear()


## Removes all UIs.
##
## Unlike remove(), this deliberately does NOT restore previous UIs.
func remove_all():
	ui_stack.clear()

	for key in active_interfaces.keys():
		_free_interface(key)

#endregion

#region QUERIES

## Returns the Interface Node of a UI given it's Key (Only if it is active)
func get_ui_instance(key: UIManager.UI) -> Interface:
	if not active_interfaces.has(key):
		push_error("Cannot get instance of inactive UI")
		return null

	return active_interfaces[key]


## Returns the currently active/top UI Key.
func get_top_ui() -> UIManager.UI:
	if ui_stack.is_empty():
		return UI.NONE

	return ui_stack.back()

#endregion

#region INTERNAL

## Frees an interface without touching the navigation stack.
func _free_interface(key: UIManager.UI) -> void:
	var interface := active_interfaces[key]

	interface.on_interface_closing()
	interface.queue_free()

	active_interfaces.erase(key)
	interface_removed.emit(key)


## Removes every occurrence of a UI from the stack.
func _remove_from_stack(key: UIManager.UI):
	for i in range(ui_stack.size() - 1, -1, -1):
		if ui_stack[i] == key:
			ui_stack.remove_at(i)


## Shows the UI underneath the current one.
## Uses show() (not invoke_ui) so the stack isn't modified a second time.
func _show_previous_ui():
	if ui_stack.is_empty():
		return

	show(ui_stack.back())

#endregion

#region STATE CONNECTIONS

## @experimental This is meant to connect UI to Observable objects,
## This way the UI is notified and kept up to date[br][br]
## This is meant to connect in the pre-built handler in the [Interface] class,
## which can later match the observable name for a quicker function dispatch.
func connect_observables(state: Resource, ui_key: UIManager.UI) -> void:
	var observables = get_all_observables(state)
	var ui_instance = get_ui_instance(ui_key)

	for observable_entry in observables:
		var observable = observable_entry["observable"]
		var observable_name = observable_entry["field_name"]

		if observable is Observable:
			var bound = ui_instance.on_observable_changed.bind(observable_name)
			observable.changed.connect(bound)

		if observable is ObservableArray:
			var bound = ui_instance.on_field_changed_array.bind(observable_name)
			var bound1 = ui_instance.on_reset_array.bind(observable_name)
			observable.field_changed.connect(bound)
			observable.reset.connect(bound1)

		if observable is ObservableDictionnary:
			var bound = ui_instance.on_field_changed_dict.bind(observable_name)
			var bound1 = ui_instance.on_reset_dict.bind(observable_name)
			observable.field_changed.connect(bound)
			observable.reset.connect(bound1)


## Given a resoruce it retrieves the property list and extracts
## all observables from it
func get_all_observables(state: Resource):
	#Array[Dictionary["observable","field_name"]]
	var observables = []

	for prop in state.get_property_list():
		if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue

		var value = state.get(prop.name)
		if value is Observable or value is ObservableArray or value is ObservableDictionnary:
			observables.append({ "observable": value, "field_name": prop.name })

	return observables

#endregion
