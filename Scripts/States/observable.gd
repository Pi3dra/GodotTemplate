class_name Observable
extends Resource

enum BEHAVIOR { ADDED, ERASED, CHANGED }

var previous_value
var _value


func _init(initial_value = null) -> void:
	_value = initial_value


var value:
	get:
		return _value
	set(new_value):
		if new_value != _value:
			previous_value = _value
			_value = new_value
			emit_changed()
