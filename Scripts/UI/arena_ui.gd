extends Control

class_name area_ui

static var instance
var cookie_tscn : PackedScene = load("res://Scenes/UI/cookie.tscn")
var cookie_list : Array[Cookie]
var cookie_instances : Array [Control] = []
var selected_cookie : Control

var screen_size : Vector2 
var screen_middle : float

var active_cookies = Cookie.type_dict() #Dictionary[TYPE, Array[Cookie]]

@onready var flip_button: Button = $Flip
@onready var cookie_holder = $PanelContainer/CookieHolder

func _ready() -> void:
	#hide()
	instance = self

	screen_size = get_viewport().get_visible_rect().size
	screen_middle = screen_size.x/2


# Called after instantiation
func init(cookies : Dictionary):
	print(cookies)
	var cookie_list : Array[Cookie] = []
	for cookie in cookies.keys():
		for i in range(cookies.get(cookie)):
			cookie_list.append(Cookie.new("","",cookie))
	cookie_holder.create_buttons(cookie_list)

func _draw() -> void:
	var to = Vector2(screen_middle, 0)
	var from = Vector2(screen_middle, screen_size.y)
	draw_line(from, to, Color.WHITE,2 )

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and selected_cookie != null:
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
		
		#### Handling pre flip Cookies
		var weighted_cookies = active_cookies.get(Cookie.TYPE.Weighted)
		var head_chance = 0
		var tail_chance = 0
		for cookie in weighted_cookies:
			# TODO put this to 15
			if cookie.side == Cookie.SCREENSIDE.Head:
				head_chance += 25
			elif cookie.side == Cookie.SCREENSIDE.Tail:
				tail_chance += 25
		var head_cookies = active_cookies.get(Cookie.TYPE.Head)
		head_chance += 15*head_cookies.size()
		
		var tail_cookies = active_cookies.get(Cookie.TYPE.Tail)
		tail_chance += 15*tail_cookies.size()
		
		#### Cookie flipping
		var correct_guesses : Array[Control]
		var incorrect_guesses : Array[Control]
	
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
			
			match cookie_object.cookie_type:
				Cookie.TYPE.Replay:
					if randf() > 0.5:
						cookie_holder.create_button(cookie_object)
				
		for cookie in incorrect_guesses:
			cookie.make_red()
			
		# Clear old effects:
		active_cookies.clear()
		
		# Handling correctly guessed cookies 
		
		var correct_guessed_cookies : Array[Cookie] = []
		for cookie_node in correct_guesses:
			correct_guessed_cookies.append(cookie_node.cookie)
			
		var active_cookie_list : Array[Cookie] = Cookie.filter_cookies_effect(correct_guessed_cookies, Cookie.EFFECTYPE.Chance)
		active_cookies = Cookie.list_to_dict(active_cookie_list)
		
		var combat_cookie_list : Array[Cookie]  = Cookie.filter_cookies_effect(correct_guessed_cookies, Cookie.EFFECTYPE.Combat)
		var combat_cookie = Cookie.list_to_dict(combat_cookie_list)
		
		print("COMBAT: ", combat_cookie, combat_cookie_list, correct_guesses)
		
		if combat_cookie.size() > 0:
			emit_signal("combat_cookies", combat_cookie)
		
	elif flip_button.text == "Accept":
		erase_cookies()
		

func erase_cookies():
	for cookie in cookie_instances:
		cookie.queue_free()
	cookie_instances.clear()
	flip_button.text = "Flip"
		
