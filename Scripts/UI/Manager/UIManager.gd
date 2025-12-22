# UIManager.gd
extends Node

class_name UIManager

var overlay_scenes: Dictionary[int, Overlay] = { }
var active_overlays: Dictionary[int, Overlay] = { }

var root_node: CanvasLayer


func init_manager(key_to_path: Dictionary, canvas_layer: CanvasLayer):
	root_node = canvas_layer

	for ui_key in key_to_path.keys():
		overlay_scenes[ui_key] = Overlay.new(ui_key, key_to_path[ui_key])


func call_overlay(key: int, caller_node: Node, data: Dictionary = { }):
	if active_overlays.has(key):
		show_overlay(key)
		return

	var caller := Caller.new(caller_node)
	var overlay: Overlay = overlay_scenes.get(key)

	if overlay == null:
		push_error("Overlay key not registered: %s" % key)
		return

	var ui_instance := overlay.instantiate_ui(caller, data)

	active_overlays[key] = overlay
	root_node.add_child(ui_instance)


func connect_to_caller(key: int, from_ui: Dictionary):
	_modify_signals(key, { }, from_ui)


func connect_to_ui(key: int, from_caller: Dictionary):
	_modify_signals(key, from_caller, { })


func connect_signals(
		key: int,
		from_caller_signals: Dictionary = { },
		from_ui_signals: Dictionary = { },
):
	_modify_signals(key, from_caller_signals, from_ui_signals, true)


func disconnect_signals(
		key: int,
		from_caller_signals: Dictionary = { },
		from_ui_signals: Dictionary = { },
):
	_modify_signals(key, from_caller_signals, from_ui_signals, false)


func _modify_signals(
		key: int,
		from_caller_signals: Dictionary,
		from_ui_signals: Dictionary,
		connect := true,
):
	if not active_overlays.has(key):
		push_error("Overlay not active: %s" % key)
		return

	var overlay := active_overlays[key]
	var caller := overlay.caller

	for signame in from_caller_signals:
		if connect:
			caller.connect_signal(signame, from_caller_signals[signame])
		else:
			caller.disconnect_signal(signame, from_caller_signals[signame])

	for signame in from_ui_signals:
		if connect:
			overlay.connect_signal(signame, from_ui_signals[signame])
		else:
			overlay.disconnect_signal(signame, from_ui_signals[signame])


func hide_overlay(key: int):
	if active_overlays.has(key):
		active_overlays[key].hide()


func show_overlay(key: int):
	if active_overlays.has(key):
		active_overlays[key].show()


func remove_overlay(key: int):
	if not active_overlays.has(key):
		push_error("Trying to remove inactive overlay")
		return

	var overlay := active_overlays[key]
	var caller := overlay.caller

	disconnect_signals(
		key,
		caller.from_ui_signals,
		overlay.from_caller_signals,
	)

	overlay.instance.queue_free()
	overlay.clear()
	active_overlays.erase(key)


func get_data(key: int) -> Dictionary:
	if not active_overlays.has(key):
		push_error("Trying to retrieve data from an inactive overlay")
		return { }
	return active_overlays[key].data


func get_ui_instance(key: int) -> Node:
	if not active_overlays.has(key):
		push_error("Cannot get instance of inactive UI")
		return null
	return active_overlays[key].instance


func get_caller_instance(key: int) -> Node:
	if not active_overlays.has(key):
		push_error("Cannot get instance of inactive Caller")
		return null
	return active_overlays[key].caller.instance

"""
Possible Pain points:


1. Overlay lifecycle events

on_overlay_opened and on_overlay_closed signals in UIManager, so callers can react globally.

Useful for analytics, debugging, or global UI coordination.


2. Stacked overlays

Right now, multiple overlays can coexist, but there’s no priority or z-order management.

Add an overlay stack so you can push_overlay and pop_overlay with proper layering.


3. Modal vs. non-modal overlays

Sometimes you want an overlay to block interaction with the caller (modal), sometimes not.

Add a modal: bool flag to Overlay.


4. Overlay re-use / caching

Currently, overlays are destroyed (queue_free) on remove_overlay.

Add an option to cache and re-use overlays (e.g., keep them hidden instead of freeing).


5. Global data passing

Right now, data is only passed on instantiation.

Add update_overlay_data(key, data: Dictionary) so overlays can refresh without reinstantiation.




"""
