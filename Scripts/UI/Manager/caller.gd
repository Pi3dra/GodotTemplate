# Caller.gd
extends RefCounted

class_name Caller

var instance: Node
var from_ui_signals: Dictionary[String, Callable] = { }


func _init(caller_instance: Node):
	instance = caller_instance


func connect_signal(signal_name: String, function: Callable):
	"""
	Connects signal from caller to UI method
	"""
	if not from_ui_signals.has(signal_name):
		instance.connect(signal_name, function)
		from_ui_signals[signal_name] = function


func disconnect_signal(signal_name: String, function: Callable):
	if from_ui_signals.has(signal_name):
		instance.disconnect(signal_name, function)
		from_ui_signals.erase(signal_name)
