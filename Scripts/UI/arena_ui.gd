extends Control

class_name area_ui

static var instance
var cookie_tscn : PackedScene = load("res://Scenes/UI/cookie.tscn")
var cookie_list : Array[Cookie]
var cookie_instances : Array [Control] = []
var selected_cookie : Control

var screen_size : Vector2 
var screen_middle : float

var active_cookies : Array#[Cookie]

@onready var flip_button: Button = $Flip
@onready var cookie_holder = $PanelContainer/CookieHolder



func _ready() -> void:
	hide()
	instance = self
	cookie_list = [
	Cookie.new("","",Globals.COOKIETYPE.Normal),
	Cookie.new("","",Globals.COOKIETYPE.Weighted),
	Cookie.new("","",Globals.COOKIETYPE.Weighted),
	Cookie.new("","",Globals.COOKIETYPE.Weighted),
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
			if selected_cookie.position.x < screen_middle:
				selected_cookie.cookie.side = Cookie.SCREENSIDE.Head
			else:
				selected_cookie.cookie.side = Cookie.SCREENSIDE.Head
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
	

signal combat_cookies(cookies: Array[Cookie])

func _on_button_pressed() -> void:
	if flip_button.text == "Flip":
		
		if cookie_instances.size() < 1:
			return
		flip_button.text = "Accept"
		var correct_guesses : Array[Control]
		var incorrect_guesses : Array[Control]
		
		#### Handling chance cookies:
		print("Active cookies ", active_cookies)
		var weighted_cookies = filter_cookies_type(active_cookies,Globals.COOKIETYPE.Weighted)
		
		var head_chance = 0
		var tail_chance = 0
		for cookie in weighted_cookies:
			if cookie.side == Cookie.SCREENSIDE.Head:
				head_chance += 50
			elif cookie.side == Cookie.SCREENSIDE.Tail:
				tail_chance += 50
		
		#### Cookie flipping
		for cookie_node in cookie_instances:
			var cookie_object : Cookie = cookie_node.cookie
			
			var result : Cookie.STATE 
			if cookie_object.side == Cookie.SCREENSIDE.Head:
				result = cookie_node.flip_coin(cookie_object.chance + head_chance)
			elif cookie_object.side == Cookie.SCREENSIDE.Tail:
				result = cookie_node.flip_coin(cookie_object.chance - head_chance)
			
			if cookie_object.state == cookie_object.side:
				correct_guesses.append(cookie_node)
			else:
				incorrect_guesses.append(cookie_node)
				
				
		for cookie in incorrect_guesses:
			cookie.make_red()
			
		# Clear old effects:
		active_cookies.clear()
		
		var active_cookie_nodes = filter_cookies_effect(correct_guesses, Cookie.EFFECTYPE.Chance)
		var combat_cookie_nodes  = filter_cookies_effect(correct_guesses, Cookie.EFFECTYPE.Combat)
		active_cookies = active_cookie_nodes.map(func(cookie_node): return cookie_node.cookie) 
		var combat_cookies = combat_cookie_nodes.map(func(cookie_node): return cookie_node.cookie) as Array[Cookie]
		
		####### DEBUG
		print("Chance Cookies:")
		for cookie in active_cookies:
			print(cookie.to_stringg())
		print()
		print("Combat Cookies:")
		for cookie in combat_cookies:
			print(cookie.to_stringg())
			
		emit_signal("combat_cookies", combat_cookies)
		
	elif flip_button.text == "Accept":
		erase_cookies()
		

func filter_cookies_effect(cookie_list : Array[Control], pEffect_type : Cookie.EFFECTYPE) -> Array[Control]:
	return cookie_list.filter(func(cookie_node):return cookie_node.cookie.effect_type == pEffect_type )

func filter_cookies_type(cookie_list : Array, pCookie_type : Globals.COOKIETYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.cookie_type == pCookie_type )


func erase_cookies():
	for cookie in cookie_instances:
		cookie.queue_free()
	cookie_instances.clear()
	flip_button.text = "Flip"
		
