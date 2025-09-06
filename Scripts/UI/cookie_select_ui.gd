extends Control

class_name cookie_select_ui

static var instance 


@onready var cookie_bar: HBoxContainer = $VBoxContainer/PanelContainer/CookierBar
@onready var accept_button : Button = $Accept

var available_cookies : Dictionary[Cookie.TYPE, int] = {}

var selected_cookie
var placed_cookies : Array #Cookie nodes

var cookie_tscn : PackedScene  = load("uid://b5dekwm16iqx0")

func _ready():
	available_cookies = UI.manager.get_data(UI.NAME.CookieSelection)
	instance = self
	accept_button.disabled = true
	update_cookie_bar()
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and selected_cookie != null:
			var cookie_panel_area = $VBoxContainer/Panel.get_global_rect()
			var cookie_area = selected_cookie.get_global_rect()
			if cookie_panel_area.encloses(cookie_area):
				selected_cookie.following = false
				selected_cookie = null
				accept_button.disabled = false

func add_to_bar(cookie):
	var label = Label.new()
	label.text = "  " +str(available_cookies[cookie]) + "X"
	label.theme_type_variation = "TextBox"
	
	var style = StyleBoxTexture.new()
	var button = Button.new()
	button.icon = Cookie.type_sprite(cookie)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("hover", style)
	#texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	#button.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	#cookie_nodes[cookietype] = [label,button]
	button.button_down.connect(_on_button_down.bind(button,label,cookie))
	cookie_bar.add_child(label)
	cookie_bar.add_child(button)
			

func _on_button_down(button,label,cookie):
	available_cookies[cookie] -= 1
	label.text =  "  " +str(available_cookies[cookie]) + "X"
	var cookie_instance = cookie_tscn.instantiate()
	var cookie_obj = Cookie.new(cookie)
	cookie_instance.cookie = cookie_obj
	selected_cookie = cookie_instance
	placed_cookies.append(cookie_instance)
	add_child(cookie_instance)
	if available_cookies[cookie] < 1:
		label.queue_free()
		button.queue_free()

func update_cookie_bar():
	for cookie in available_cookies.keys():
		if available_cookies[cookie] > 0:
			add_to_bar(cookie)


func _on_exit_pressed() -> void:
	SoundManager.instance.play_sound("Click2", true, false)
	#TODO: restart the selected battle
	UI.manager.remove_overlay(UI.NAME.CookieSelection)


signal selected_cookie_deck(cookies)
func _on_accept_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	var chosen_cookies : Array = placed_cookies.map(func(cookie_node): return cookie_node.cookie.cookie_type)
	var counted_cookies : Dictionary[Cookie.TYPE, int]= {}
	for cookie in chosen_cookies:
		counted_cookies.set(cookie, counted_cookies.get_or_add(cookie,0) + 1)
	emit_signal("selected_cookie_deck", counted_cookies)
	UI.manager.remove_overlay(UI.NAME.CookieSelection)


func _on_exit_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_exit_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic


func _on_accept_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_accept_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
