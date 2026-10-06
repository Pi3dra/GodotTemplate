## EXPERIMENTAL, The goal of this class is to provide a generic and easy to use object,
## To make view models accurately keep up with the data
class_name Observable
extends Resource

# This is used for more complex observable classes like dicts and arrays!
enum BEHAVIOR { ADDED, CHANGED, ERASED }
signal value_changed(new_value, old_value)

var _value


func _init(initial_value = null) -> void:
	_value = initial_value


var value:
	get:
		return _value
	set(new_value):
		if new_value != _value:
			var old = _value # local: lives only during this call
			_value = new_value
			value_changed.emit(new_value, old)
			emit_changed() # optional, for Resource compatibility
