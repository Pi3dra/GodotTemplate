class_name Main

extends Node

static var instance

#var cursor_arrow = load("uid://cx236dmj8d3of")
#var cursor_cross = load("uid://dobp4rb1bwcgq")
#var cursor_chat = load("uid://b12scfgqlfot6")
#var cursor_eye = load("uid://bpth3y6r1j4yi")
#var cursor_step = load("uid://dhppjphh0s3i0")
#var cursor_point = load("uid://6fwvqeuj7i76")
#var cursor_can_grab = load("uid://b8i43ph5o33yy")
#var cursor_grab = load("uid://bgia6uov3da1a")

#//////////function//////////
func _ready() -> void:
	instance = self
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#
	#Input.set_custom_mouse_cursor(cursor_arrow)
	#Input.set_custom_mouse_cursor(cursor_cross, Input.CURSOR_FORBIDDEN)
	#Input.set_custom_mouse_cursor(cursor_chat, Input.CURSOR_HELP)
	#Input.set_custom_mouse_cursor(cursor_eye, Input.CURSOR_IBEAM)
	#Input.set_custom_mouse_cursor(cursor_step, Input.CURSOR_MOVE)
	#Input.set_custom_mouse_cursor(cursor_point, Input.CURSOR_POINTING_HAND)
	#Input.set_custom_mouse_cursor(cursor_can_grab, Input.CURSOR_CAN_DROP)
	#Input.set_custom_mouse_cursor(cursor_grab, Input.CURSOR_DRAG)
