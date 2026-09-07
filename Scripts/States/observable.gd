class_name Observable
extends RefCounted

# This is actually used by ObservableArray and ObservableDict 
enum BEHAVIOR {ERASED, ADDED, CHANGED}
# This is an observable object it is meant to be used by the states shared with the UI
# when it's value changes it will signal all connected UI elements 
signal changed(new_value, old_value)

# This could be imroved by adding an owner which would allow
# to propagate the changed emissions up the ownership stack in nested structs

var _value

func _init(initial_value = null, owner = null) -> void:
	_value = initial_value
var value:
	get:
		return _value
	set(new_value):
		if new_value != _value:
			var old = _value
			_value = new_value
			changed.emit(new_value, old)
