class_name ObservableArray
extends RefCounted

signal field_changed(old_value, new_value, key, behavior)
signal reset(items: Array)

var _items: Array = []

func _init(initial: Array = []) -> void:
	_items = initial.duplicate()

# callers get a copy, can't mutate behind your back
var items: Array:
	get: return _items.duplicate()   
func add(item) -> void:
	_items.append(item)
	field_changed.emit(null, item, len(_items) - 1, Observable.BEHAVIOR.ADDED)

func remove_at(index: int) -> void:
	var item = _items[index]
	_items.remove_at(index)
	field_changed.emit(item, null, index, Observable.BEHAVIOR.ERASED)
	
func set_at(value, index: int) -> void:
	var old_value = _items[index]
	_items[index] = value
	field_changed.emit(old_value, value, index, Observable.BEHAVIOR.CHANGED)

func replace_all(new_items: Array) -> void:
	_items = new_items.duplicate()
	reset.emit(_items)
