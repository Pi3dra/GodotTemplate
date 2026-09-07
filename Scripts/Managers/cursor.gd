extends TextureRect

var offset = Vector2(16,16)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	texture = load("uid://dwwfgibmxmk46")

func _process(_delta):
	position = get_global_mouse_position() - offset
	
	RefCounted
