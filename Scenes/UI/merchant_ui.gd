extends Control

class_name merchant_ui

var instance = self

var current_index = 0
var current_panels = []
@onready var right_button = $VBoxContainer/HBoxContainer2/Right
@onready var left_button = $VBoxContainer/HBoxContainer2/Left
@onready var cookie_bar: HBoxContainer = $VBoxContainer/PanelContainer/CookierBar

var available_cookies : Dictionary[Cookie.TYPE, int] = {Cookie.TYPE.Normal : 2, Cookie.TYPE.Vampire: 1}
var cookie_nodes : Dictionary [Cookie.TYPE, Array]= {} # [Cookie.TYPE, [Label, TextureRect]

func _ready():
	for child in $VBoxContainer/HBoxContainer2.get_children():
		if child is not Button:
			current_panels.append(child)
			child.connect("buy_cookie", buy_cookie)
			child.connect("sell_cookie", sell_cookie)
	update_panels()
	update_button_status()
	update_panels()
	cookie_nodes = init_cookie_bar()
	instance = self

func init_cookie_bar():
	var dict : Dictionary[Cookie.TYPE, Array] = {}
	for cookie in available_cookies.keys():
		var label = Label.new()
		#print("cookie: ", cookie ," in dict: ",available_cookies.get(cookie), " dict: ", available_cookies)
		label.text = "  " +str(available_cookies[cookie]) + "X"
		label.theme_type_variation = "TextBox"
		var texture = TextureRect.new()
		texture.texture = Cookie.type_sprite(cookie)
		texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE

		dict[cookie] = [label,texture]
		cookie_bar.add_child(label)
		cookie_bar.add_child(texture)
	return dict
	
func buy_cookie(cookietype, price):
	available_cookies[Cookie.TYPE.Normal] -= price
	if !available_cookies.has(cookietype):
		available_cookies.set(cookietype, 1)
	else:
		available_cookies[cookietype] += 1
	update_cookie_bar()
	update_panels()
	
	
func sell_cookie(cookietype, price):
	print("test")
	available_cookies[Cookie.TYPE.Normal] += price
	available_cookies[cookietype] -= 1
	update_cookie_bar()
	update_panels()
	print(available_cookies)


func update_cookie_bar():
	print(available_cookies)
	for cookietype in available_cookies.keys():
		print(cookietype)
		if available_cookies[cookietype] == 0:
			print("ctype: ", cookietype)
			var nodes = cookie_nodes[cookietype]
			var text = nodes[0]
			var icon = nodes[1]
			text.hide()
			icon.hide()
		elif !cookie_nodes.has(cookietype):
			var label = Label.new()
			label.text = "  " +str(available_cookies[cookietype]) + "X"
			label.theme_type_variation = "TextBox"
			var texture = TextureRect.new()
			texture.texture = Cookie.type_sprite(cookietype)
			texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	
			cookie_nodes[cookietype] = [label,texture]
			cookie_bar.add_child(label)
			cookie_bar.add_child(texture)
			
		else:
			var nodes = cookie_nodes[cookietype]
			var text = nodes[0]
			text.show()
			var icon = nodes[1]
			icon.show()
			text.text = "  " +str(available_cookies[cookietype]) + "X"

func update_panels():
	var counter = 0
	for panel in current_panels:
		panel.update_panel(Cookie.TYPE.values()[current_index + counter],false)
		counter += 1
		panel.update_buttons(available_cookies)

func _on_right_pressed() -> void:
	if current_index + 1 < Cookie.TYPE.values().size() - 2:
		current_index +=1
		update_panels()
		update_button_status()

func _on_left_pressed() -> void:
	if current_index - 1 >= 0:
		current_index -=1
		update_panels()
		update_button_status()
		
func update_button_status():
	if current_index > 0:
		left_button.disabled = false
	elif current_index == 0:
		left_button.disabled = true

	if current_index + 1 ==  Cookie.TYPE.values().size() - 2:
		right_button.disabled = true
	elif current_index  < Cookie.TYPE.values().size() - 2:
		right_button.disabled = false
	
	
	

signal update_cookies(cookies)
func _on_exit_pressed() -> void:
	emit_signal("update_cookies", available_cookies )
	queue_free()
