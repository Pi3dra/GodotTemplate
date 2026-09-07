# UIManager.gd
extends Node

class_name UIManager
## HOW TO USE THIS
##
##
## 1. Create new [b]UI[/b] tscn, extending the [Interface] class (interface.gd) [br]
## 2. Add a new entry in the [enum UIManager.UI] enum 
##    and [member UIManager.UI_PATHS] dictionary in (ui_manager.gd)[br]
## 4. You can override different [b]callbacks[/b] shown in (interface.gd)[br]
## 5. You can finally show any UI with: 
##    [code]UI.manager.invoke_ui(UI.manager.UI.MAIN_MENU)[/code][br]


# TODO add connect and disconnect functions, so that game scenes can connect special 
# signals to the ui
#
# TODO add connection to observable states and keep a mapping,
# so if the ui is removes we can bring it back with its correct state
#
# TODO maybe do statemanager? any game scene can export states to it with observable
# or not variables, so that when a UI spawns if it knows which state it needs it can
# automatically connect to it and its observables, as well as access them easily with
# something like state.varname
#
# 
#


## This is where the user should add their UIs mapped to their corresponding UID
enum UI {NONE, MAIN_MENU, SETTINGS }
const UI_PATHS = {
	UI.MAIN_MENU: "uid://i8c14jrjxiq8",
	UI.SETTINGS: "uid://crb7lkmq7wr6",
}

var instance: UIManager
var active_interfaces: Dictionary[UIManager.UI, Interface] = {}

# The UI navigation stack.
# Last element = currently active/top UI.
var ui_stack: Array[UIManager.UI] = []

var root_node: CanvasLayer

enum DisplayMode { ON_TOP, HIDE, REMOVE }


signal interface_shown(key: UI)
signal interface_hidden(key: UI)
signal interface_created(key: UI)
signal interface_removed(key: UI)


func _init(canvas_layer: CanvasLayer):
	root_node = canvas_layer


## Shows an existing UI or creates it if necessary.
func invoke_ui(key: UIManager.UI):
	if active_interfaces.has(key):
		show(key)
		return

	var interface_path: PackedScene = load(UI_PATHS.get(key))

	if interface_path == null:
		push_error("interface key not registered: %s" % key)
		return

	var interface: Interface = interface_path.instantiate()
	interface.key = key

	interface.on_interface_created()
	interface_created.emit(key)

	active_interfaces[key] = interface
	root_node.add_child(interface)


## Switch to another UI.
##
## ON_TOP:
##     Current UI stays visible underneath the new UI.
##
## HIDE:
##     Current UI is hidden, and the new UI is put on top.
##     When the new UI is hidden, the previous UI comes back.
##
## REMOVE:
##     Current UI is removed, and the new UI is put on top.
##     When the new UI is removed, the previous UI comes back.
func switch_ui(
	key: UIManager.UI,
	display_mode: DisplayMode = DisplayMode.ON_TOP
):
	var current := get_top_ui()

	match display_mode:
		DisplayMode.ON_TOP:
			if current != key:
				ui_stack.append(key)

		DisplayMode.HIDE:
			if current != UI.NONE and current != key:
				hide_all()
				ui_stack.append(key)

		DisplayMode.REMOVE:
			if current != UI.NONE and current != key:
				remove_all()
				ui_stack.append(key)

	# Make sure the requested UI exists.
	invoke_ui(key)

	# If this UI was already somewhere in the stack, remove the old entry.
	# This prevents:
	# GAME -> SETTINGS -> GAME -> SETTINGS
	# from creating a broken stack.
	for i in range(ui_stack.size() - 2, -1, -1):
		if ui_stack[i] == key:
			ui_stack.remove_at(i)

	# Ensure key is the top of the stack.
	if ui_stack.is_empty() or ui_stack.back() != key:
		ui_stack.append(key)


## Hides a UI.
##
## If it was the top UI, the previous UI in the stack is shown again.
func hide(key: UIManager.UI):
	if not active_interfaces.has(key):
		return

	var interface := active_interfaces[key]

	interface.hide()
	interface_hidden.emit(key)

	# Remove it from the navigation stack.
	var was_top = ui_stack.back() == key if not ui_stack.is_empty() else false
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

	var was_top = ui_stack.back() == key if not ui_stack.is_empty() else false

	_remove_from_stack(key)

	var interface := active_interfaces[key]

	interface.on_interface_closing()
	interface.queue_free()

	interface_removed.emit(key)

	active_interfaces.erase(key)

	# Restore the previous UI.
	if was_top:
		_show_previous_ui()


## Removes all UIs.
##
## Unlike remove(), this deliberately does NOT restore previous UIs.
func remove_all():
	var keys := active_interfaces.keys().duplicate()

	# Clear the stack first so remove() doesn't try to restore things.
	ui_stack.clear()

	for key in keys:
		if not active_interfaces.has(key):
			continue

		var interface := active_interfaces[key]

		interface.on_interface_closing()
		interface.queue_free()

		interface_removed.emit(key)
		active_interfaces.erase(key)


## Hides all UIs.
##
## Unlike hide(), this deliberately does NOT restore previous UIs.
func hide_all():
	var keys := active_interfaces.keys().duplicate()

	for key in keys:
		if active_interfaces.has(key):
			var interface := active_interfaces[key]
			interface.hide()
			interface_hidden.emit(key)

	ui_stack.clear()


func show(key: UIManager.UI):
	if not active_interfaces.has(key):
		invoke_ui(key)
		return

	var interface := active_interfaces[key]

	interface.show()
	interface.on_interface_shown()
	interface_shown.emit(key)


func get_ui_instance(key: UIManager.UI) -> Interface:
	if not active_interfaces.has(key):
		push_error("Cannot get instance of inactive UI")
		return null

	return active_interfaces[key]


## Returns the currently active/top UI.
func get_top_ui() -> UIManager.UI:
	if ui_stack.is_empty():
		return UI.NONE

	return ui_stack.back()


## Removes every occurrence of a UI from the stack.
func _remove_from_stack(key: UIManager.UI):
	for i in range(ui_stack.size() - 1, -1, -1):
		if ui_stack[i] == key:
			ui_stack.remove_at(i)


## Shows the UI underneath the current one.
func _show_previous_ui():
	if ui_stack.is_empty():
		return

	var previous = ui_stack.back()

	if active_interfaces.has(previous):
		show(previous)
		
		
#region STATE CONNECTIONS

# this is what allows the ui to connect to a given game state


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
			
func get_all_observables(state: Resource):
	var observables = []
	
	for prop in state.get_property_list():
		if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
			
		var value = state.get(prop.name)
		if value is Observable or value is ObservableArray or value is ObservableDictionnary: 
			observables.append({"observable": value, "field_name": prop.name})
