# UIManager.gd
extends Node

class_name UIManager
## HOW TO USE THIS
##
##
## 1. Create new [b]UI[/b] tscn, extending the [Interface] class (interface.gd) [br]
## 2. Add a new entry in the [enum UIManager.UI] enum 
##    and [member UIManager.UI_PATHS] dictionary in (ui_manager.gd)[br]
## 3. You can connect [b]signals[/b] from elsewhere with: 
##    [code]UI.manager.connect("signal_name")[/code][br]
## 4. You can override different [b]callbacks[/b] shown in (interface.gd)[br]
## 5. You can finally show any UI with: 
##    [code]UI.manager.invoke_ui(UI.manager.UI.MAIN_MENU)[/code][br]

## This is where the user should add their UIs mapped to their corresponding UID
enum UI { MAIN_MENU, SETTINGS }
const UI_PATHS = {
	UI.MAIN_MENU: "uid://i8c14jrjxiq8",
	UI.SETTINGS: "uid://crb7lkmq7wr6",
}

var active_interfaces: Dictionary[UIManager.UI, Interface] = { }
var root_node: CanvasLayer

## These signals are used to trigger events when certain actions occur
## Do not connect them to Interface nodes, the callbacks of the class are made for this

signal interface_shown(key: UI)
signal interface_hidden(key: UI)
signal interface_created(key: UI)
signal interface_removed(key: UI)


func _init(canvas_layer: CanvasLayer):
	root_node = canvas_layer


## If the given UI is hidden, it shows it, else it instantiates it
func invoke_ui(key: UIManager.UI):
	if active_interfaces.has(key):
		show(key)
		return

	var interface_path: PackedScene = load(UI_PATHS.get(key))

	if interface_path == null:
		push_error("interface key not registered: %s" % key)
		return

	#Instantiates a given intance and
	var interface: Interface = interface_path.instantiate()
	interface.key = key

	interface.on_interface_created()
	interface_created.emit(key)

	active_interfaces[key] = interface
	root_node.add_child(interface)


## Removes or hides all current UI, to display only the given Interface
## TODO: Might be interesting to add scheduling, i.e initially hide UIs, and
## queue free them after a certain timeout
## TODO: Move main structure to an actual stack, this allows switching menus super easy
func switch_ui(key: UIManager.UI, hide_uis: bool):
	if hide_uis:
		hide_all()
	else:
		remove_all()

	invoke_ui(key)


func hide(key: UIManager.UI):
	if active_interfaces.has(key):
		active_interfaces[key].hide()
		interface_hidden.emit(key)


func hide_all():
	for ui_key in active_interfaces.keys():
		hide(ui_key)


func remove(key: UIManager.UI):
	if not active_interfaces.has(key):
		push_error("Trying to remove inactive interface")
		return

	var interface := active_interfaces[key]

	interface.on_interface_closing()
	interface.queue_free()
	interface_removed.emit(key)
	active_interfaces.erase(key)


func remove_all():
	for ui_key in active_interfaces.keys():
		remove(ui_key)


func show(key: UIManager.UI):
	if active_interfaces.has(key):
		var interface = active_interfaces[key]
		interface.show()
		interface.on_interface_opened()
		interface_shown.emit(key)


func get_ui_instance(key: UIManager.UI) -> Interface:
	if not active_interfaces.has(key):
		push_error("Cannot get instance of inactive UI")
		return null
	return active_interfaces[key]
