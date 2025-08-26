extends Control

class_name area_ui

static var instance
var cookie_tscn : PackedScene = load("res://Scenes/UI/cookie.tscn")
var cookie_list : Array[Cookie]
var cookie_instances : Array [Control] = []
var selected_cookie : Control

var screen_size : Vector2 
var screen_middle : float


@onready var flip_button: Button = $Flip
@onready var cookie_holder = $PanelContainer/CookieHolder



func _ready() -> void:
	hide()
	instance = self
	cookie_list = [
	Cookie.new("","",Globals.COOKIETYPE.Normal),
	Cookie.new("","",Globals.COOKIETYPE.Weighted),
	Cookie.new("","",Globals.COOKIETYPE.Berserk),
	Cookie.new("","",Globals.COOKIETYPE.Crit),
	Cookie.new("","",Globals.COOKIETYPE.Golden),
	Cookie.new("","",Globals.COOKIETYPE.Healing),
	Cookie.new("","",Globals.COOKIETYPE.Vampire),
	Cookie.new("","",Globals.COOKIETYPE.Replay),
	]

	cookie_holder.create_buttons(cookie_list)
	screen_size = get_viewport().get_visible_rect().size
	screen_middle = screen_size.x/2

func _draw() -> void:
	var to = Vector2(screen_middle, 0)
	var from = Vector2(screen_middle, screen_size.y)
	draw_line(from, to, Color.WHITE,10 )

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected_cookie != null:
			selected_cookie.following = false
			selected_cookie = null

func _on_cookie_holder_instantiate_cookie(cookie: Cookie, button: Button) -> void:
	if flip_button.text == "Accept":
		return
		
	var cookie_instance = cookie_tscn.instantiate()
	cookie_instance.cookie = cookie
	
	cookie_holder.free_button(button)
	cookie_instances.append(cookie_instance)
	
	selected_cookie = cookie_instance
	add_child(cookie_instance)
	

func _on_button_pressed() -> void:
	if flip_button.text == "Flip":
		if cookie_instances.size() < 1:
			return
		flip_button.text = "Accept"
		var correct_guesses : Array
		var incorrect_guesses : Array
		for cookie in cookie_instances:
			var result = cookie.flip_coin(50)
			# Left -> HEAD
			if cookie.position.x < screen_middle:
				if result == "HEAD":
					correct_guesses.append(cookie)
				else:
					incorrect_guesses.append(cookie)
			elif cookie.position.x > screen_middle:
				if result == "TAIL":
					correct_guesses.append(cookie)
				else:
					incorrect_guesses.append(cookie)
					
		for cookie in incorrect_guesses:
			cookie.make_red()
			
	elif flip_button.text == "Accept":
		for cookie in cookie_instances:
			cookie.queue_free()
		cookie_instances.clear()
		flip_button.text = "Flip"
		
			
			
		
