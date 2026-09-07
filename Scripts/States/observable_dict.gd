class_name ObservableDictionnary
extends RefCounted

signal field_changed(old_value, new_value, key, behavior)
signal reset(items: Array)

var _items: Dictionary = {}

func _init(initial: Dictionary = {}) -> void:
	_items = initial.duplicate()

# callers get a copy, can't mutate behind your back
var items: Dictionary:
	get: return _items.duplicate()   
	
func add(item, key) -> void:
	_items[key] = item
	field_changed.emit(null, item, key, Observable.BEHAVIOR.ADDED)

func remove_at(key) -> void:
	var item = _items[key]
	_items.erase(key)
	field_changed.emit(item,null, key, Observable.BEHAVIOR.ERASED)
	
func set_at(item, key) -> void:
	var old_value = _items[key]
	_items[key] = item
	field_changed.emit(old_value, item, key, Observable.BEHAVIOR.CHANGED)
	
func replace_all(new_items: Dictionary) -> void:
	_items = new_items.duplicate()
	reset.emit(_items)
