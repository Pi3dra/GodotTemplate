extends Control

@onready var texture_panel = $VBoxContainer/PanelContainer/TextureRect
@onready var description_box = $VBoxContainer/Description
@onready var cookie_title = $Panel/CookieName
@onready var price = $VBoxContainer/HBoxContainer/Price
@onready var buy: Button = $HBoxContainer/Buy
@onready var sell: Button = $HBoxContainer/Sell

var cookie_type : Cookie.TYPE
var cookie_price : int

func _ready():
	sell.disabled = true
	buy.disabled = true


func update_buttons(available_cookies : Dictionary[Cookie.TYPE,int]):
	if available_cookies[Cookie.TYPE.Normal] < cookie_price:
		buy.disabled = true
	else:
		buy.disabled = false
		
	#This here might be bugged
	#print( available_cookies.has(cookie_type)  && available_cookies[cookie_type], cookie_type)
	if available_cookies.has(cookie_type) && available_cookies[cookie_type] > 0:
		sell.disabled = false
	else:
		sell.disabled = true
	#print(sell.disabled)
	
	
func update_panel(cookie : Cookie.TYPE, locked : bool):
	cookie_type = cookie
	cookie_price = Cookie.type_price(cookie)

	if cookie_type == Cookie.TYPE.Normal:
		buy.hide()
		sell.hide()
		price.hide()
	else:
		buy.show()
		sell.show()
		price.show()
	
	if locked:
		texture_panel.texture = null
		description_box.text = "Locked"
		cookie_title.text = "Locked"
		price.text = ""
	else:
		texture_panel.texture = Cookie.type_sprite(cookie)
		description_box.text = Cookie.type_description(cookie)
		cookie_title.text = Cookie.TYPE.keys()[cookie] + " Cookie"
		price.text = "Price: " +  str(Cookie.type_price(cookie)) + "X"


signal buy_cookie(type, price)
func _on_buy_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	print("emitted buy")
	emit_signal("buy_cookie", cookie_type, cookie_price)


signal sell_cookie(type, price)
func _on_sell_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	print("emitted sell")
	emit_signal("sell_cookie", cookie_type, cookie_price)


func _on_sell_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_sell_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic


func _on_buy_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_buy_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
