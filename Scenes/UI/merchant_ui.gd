extends Control

var current_index = 0
var current_panels = []
@onready var right_button = $VBoxContainer/HBoxContainer2/Right
@onready var left_button = $VBoxContainer/HBoxContainer2/Left
@onready var cookie_bar: HBoxContainer = $VBoxContainer/PanelContainer/CookierBar

var available_cookies : Dictionary[Cookie.TYPE, int] = {Cookie.TYPE.Normal : 2, Cookie.TYPE.Vampire: 1}

var cookie_nodes : Dictionary = {} # [Cookie.TYPE, [Label, TextureRect]

func _ready():
	for child in $VBoxContainer/HBoxContainer2.get_children():
		if child is not Button:
			current_panels.append(child)
	update_panels()
	update_button_status()
	update_panels()
	cookie_nodes = init_cookie_bar()

func init_cookie_bar():
	var dict 
	for cookie in available_cookies.keys():
		var label = Label.new()
		print("cookie: ", cookie ," in dict: ",available_cookies.get(cookie), " dict: ", available_cookies)
		label.text = str(available_cookies[cookie]) + "X"
		var texture = TextureRect.new()
		texture.texture = Cookie.type_sprite(cookie)
		dict[cookie] = [label,texture]
		cookie_bar.add_child(label)
		cookie_bar.add_child(texture)
	return dict
	

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
	
	
	
	
