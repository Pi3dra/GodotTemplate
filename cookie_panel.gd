extends Control


func _ready():
	$VBoxContainer/PanelContainer/TextureRect.texture = Cookie.type_sprite(Cookie.TYPE.Normal)
	$VBoxContainer/Description.text = Cookie.type_description(Cookie.TYPE.Normal)
	$Panel/CookieName.text = Cookie.TYPE.keys()[Cookie.TYPE.Normal] + " Cookie"
