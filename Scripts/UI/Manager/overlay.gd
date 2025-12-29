# Overlay.gd
extends RefCounted

class_name Overlay

var key: int
var tscn_path: String

var instance: Node
var caller: Caller
var data

var from_caller_signals: Dictionary[String, Callable] = { }
var hidden := false


func _init(overlay_key: int, path: String):
	key = overlay_key
	tscn_path = path


func instantiate_ui(instance_caller: Caller, init_data: Dictionary = { }) -> Node:
	var packed_scene: PackedScene = load(tscn_path)
	instance = packed_scene.instantiate()

	caller = instance_caller
	data = init_data
	hidden = false

	return instance


func connect_signal(signal_name: String, function: Callable):
	"""
	Connects signal from overlay to caller method
	"""
	if not from_caller_signals.has(signal_name):
		instance.connect(signal_name, function)
		from_caller_signals[signal_name] = function


func disconnect_signal(signal_name: String, function: Callable):
	if from_caller_signals.has(signal_name):
		instance.disconnect(signal_name, function)
		from_caller_signals.erase(signal_name)


func hide():
	if not hidden:
		instance.hide()
		hidden = true


func show():
	if hidden:
		instance.show()
		hidden = false


func clear():
	instance = null
	caller = null
	data.clear()
	from_caller_signals.clear()
	hidden = false
