extends TextureRect

class_name Cursor

static var basic = load("uid://cx236dmj8d3of")
static var cross = load("uid://dobp4rb1bwcgq")
static var chat = load("uid://b12scfgqlfot6")
static var eye = load("uid://bpth3y6r1j4yi")
static var step = load("uid://dhppjphh0s3i0")
static var grab = load("uid://bgia6uov3da1a")
static var can_grab = load("uid://b8i43ph5o33yy")
static var point = load("uid://6fwvqeuj7i76")

static var instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self

func _process(_delta):
	position = get_viewport().get_mouse_position()
	
