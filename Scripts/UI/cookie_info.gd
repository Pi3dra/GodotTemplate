extends Control

@onready var texture_panel = $VBoxContainer/PanelContainer/TextureRect
@onready var description_box = $VBoxContainer/Description
@onready var cookie_title = $Panel/CookieName

var cookie_type: Cookie.TYPE
var cookie_price: int


func _ready():
	pass


func update_panel(cookie: Cookie.TYPE, locked: bool = false):
	cookie_type = cookie
	var cookie_data = Globals.get_cookie_data(cookie_type)
	cookie_price = cookie_data.price

	if locked:
		texture_panel.texture = null
		description_box.text = "Locked"
		cookie_title.text = "Locked"
	else:
		texture_panel.texture = cookie_data.head_texture
		description_box.text = cookie_data.description
		cookie_title.text = Cookie.TYPE.keys()[cookie] + " Cookie"
