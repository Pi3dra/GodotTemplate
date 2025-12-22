extends Control

var current_index = 0
var current_panels = []

@onready var right_button = $VBoxContainer/HBoxContainer2/Right
@onready var left_button = $VBoxContainer/HBoxContainer2/Left
@onready var cookie_bar: HBoxContainer = $VBoxContainer/PanelContainer/CookierBar

var available_cookies: Dictionary = { } #[Cookie.Type, int]
var cookie_nodes: Dictionary[Cookie.TYPE, Array] = { } # [Cookie.TYPE, [Label, TextureRect]


func _ready():
	available_cookies = UI.manager.get_data(UI.NAME.MERCHANT)
	for child in $VBoxContainer/HBoxContainer2.get_children():
		if child is not Button:
			current_panels.append(child)
			child.connect("buy_cookie", buy_cookie)
			child.connect("sell_cookie", sell_cookie)
	update_panels()
	update_button_status()
	update_cookie_bar()


func buy_cookie(cookietype, price):
	available_cookies[Cookie.TYPE.NORMAL] -= price
	if !available_cookies.has(cookietype):
		available_cookies.set(cookietype, 1)
	else:
		available_cookies[cookietype] += 1
	update_cookie_bar()
	update_panels()


func sell_cookie(cookietype, price):
	available_cookies[Cookie.TYPE.NORMAL] += price
	available_cookies[cookietype] -= 1
	update_cookie_bar()
	update_panels()


func update_cookie_bar():
	for cookietype in available_cookies.keys():
		if !cookie_nodes.has(cookietype) and available_cookies[cookietype] > 0:
			var label = Label.new()
			label.text = "  " + str(available_cookies[cookietype]) + "X"
			label.theme_type_variation = "TextBox"
			var texture = TextureRect.new()
			texture.texture = Globals.get_cookie_data(cookietype).head_texture
			texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE

			cookie_nodes[cookietype] = [label, texture]
			cookie_bar.add_child(label)
			cookie_bar.add_child(texture)

		elif available_cookies[cookietype] == 0 and cookie_nodes.has(cookietype):
			var nodes = cookie_nodes[cookietype]
			var text = nodes[0]
			text.hide()
			var icon = nodes[1]
			icon.hide()
		elif cookie_nodes.has(cookietype) and available_cookies[cookietype] > 0:
			var nodes = cookie_nodes[cookietype]
			var text = nodes[0]
			text.show()
			var icon = nodes[1]
			icon.show()
			text.text = "  " + str(available_cookies[cookietype]) + "X"


func update_panels():
	var counter = 0
	for panel in current_panels:
		panel.update_panel(Cookie.TYPE.values()[current_index + counter], false)
		counter += 1
		panel.update_buttons(available_cookies)


func _on_right_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	if current_index + 1 < Cookie.TYPE.values().size() - 2:
		current_index += 1
		update_panels()
		update_button_status()


func _on_left_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	if current_index - 1 >= 0:
		current_index -= 1
		update_panels()
		update_button_status()


func update_button_status():
	if current_index > 0:
		left_button.disabled = false
	elif current_index == 0:
		left_button.disabled = true

	if current_index + 1 == Cookie.TYPE.values().size() - 2:
		right_button.disabled = true
	elif current_index < Cookie.TYPE.values().size() - 2:
		right_button.disabled = false


signal exited_merchant(cookies)


func _on_exit_pressed() -> void:
	SoundManager.instance.play_sound("Click2", true, false)
	emit_signal("exited_merchant", available_cookies)
	UI.manager.remove_overlay(UI.NAME.MERCHANT)


func _on_exit_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_exit_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic


func _on_right_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_right_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic


func _on_left_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_left_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
