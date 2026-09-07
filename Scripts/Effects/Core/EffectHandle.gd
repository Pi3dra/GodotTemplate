class_name EffectHandle
extends RefCounted


signal finished

var _is_finished := false


func complete() -> void:
	if _is_finished:
		return

	_is_finished = true
	finished.emit()


func is_finished() -> bool:
	return _is_finished
