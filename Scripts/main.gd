class_name Main

extends Node

static var instance


#//////////function//////////
func _ready() -> void:
	instance = self
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
