extends Control



var cookie_tscn : PackedScene = load("res://Scenes/UI/cookie.tscn")
var cookie_list : Array[Cookie]
var cookie_instances : Array [Control] = []
var selected_cookie : Control


var active_cookies = Cookie.type_dict() #Dictionary[TYPE, Array[Cookie]]

@onready var flip_button: Button = $Flip
@onready var cookie_holder = $PanelContainer/CookieHolder

func _ready() -> void:
	var cookies = UI.manager.get_data(UI.NAME.Arena)
	for cookie in cookies.keys():
		for i in range(cookies.get(cookie)):
			cookie_list.append(Cookie.new(cookie))
	cookie_holder.create_buttons(cookie_list)
	
	UI.manager.connect_to_ui(UI.NAME.Arena,{"drop_cookie":instantiate_cookie})
	
	#hide()
	var tutorialbutton = $TutorialExit
	if Globals.training:
		tutorialbutton.show()
	else:
		tutorialbutton.hide()
	$Flip.position.y -= 120

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and selected_cookie != null and get_global_mouse_position().y > 200:
			selected_cookie.following = false
			selected_cookie = null
			


func _on_cookie_holder_instantiate_cookie(cookie: Cookie, button: Button) -> void:
	if flip_button.text == "Next":
		return
		
	var cookie_instance = cookie_tscn.instantiate()
	cookie_instance.cookie = cookie
	
	cookie_instances.append(cookie_instance)
	
	selected_cookie = cookie_instance
	cookie_holder.free_button(button)

	add_child(cookie_instance)
	

func instantiate_cookie(cookie: Cookie, pos):
	var cookie_instance = cookie_tscn.instantiate()
	cookie_instance.cookie = cookie
	cookie_instances.append(cookie_instance)
	cookie_instance.position = pos
	cookie_instance.following = false
	selected_cookie = null
	add_child(cookie_instance)
	cookie_instance.animate_spawning()

signal combat_cookies(cookies: Array[Cookie], enemy: bool)
func _on_button_pressed() -> void:
	SoundManager.instance.play_sound("Click3", true, false)
	if flip_button.text == "Flip":
		
		if cookie_instances.size() < 1:
			return
		flip_button.text = "Next"
		
		#### Handling pre flip Cookies
		var weighted_cookies = active_cookies.get(Cookie.TYPE.Weighted)
		var head_chance = 0
		#for cookie in weighted_cookies:
		#	# TODO put this to 15
		#	if cookie.side == Cookie.SCREENSIDE.Head:
		#		head_chance += 25
		
		var head_cookies = active_cookies.get(Cookie.TYPE.Head)
		head_chance += 15*head_cookies.size()
		
		# TODO: Leave only weihgted cookie
		#var tail_cookies = active_cookies.get(Cookie.TYPE.Tail)
		#tail_chance += 30*tail_cookies.size()
		
		#### Cookie flipping
		var correct_guesses : Array[Control]
		var incorrect_guesses : Array[Control]
	
		for cookie_node in cookie_instances:
			var cookie_object : Cookie = cookie_node.cookie
			cookie_node.flip_coin(cookie_object.chance + head_chance)
			
			if cookie_object.state == Cookie.STATE.Head:
				correct_guesses.append(cookie_node)
			elif cookie_object.state == Cookie.STATE.Tail:
				incorrect_guesses.append(cookie_node)

			match cookie_object.cookie_type:
				Cookie.TYPE.Replay:
					if randf() > 0.5:
						cookie_holder.create_button(cookie_object)

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
		
		
		# Handling Incorrectly guessed ones
		#var incorrect_guessed_cookies : Array[Cookie] = []
		#for cookie_node in incorrect_guesses:
		#incorrect_guessed_cookies.append(cookie_node.cookie)

		#var enemy_combat_cookie_list : Array[Cookie]  = Cookie.filter_cookies_effect(incorrect_guessed_cookies, Cookie.EFFECTYPE.Combat)
		#var enemy_combat_cookie = Cookie.list_to_dict(enemy_combat_cookie_list)
		
		if combat_cookie.size() > 0:
			emit_signal("combat_cookies", combat_cookie, false)
		#if enemy_combat_cookie.size() > 0:
			#emit_signal("combat_cookies", enemy_combat_cookie, true)
		
	elif flip_button.text == "Next":
		erase_cookies()
		

func erase_cookies():
	var erased_cookies = cookie_instances.duplicate()
	for cookie in cookie_instances:
		if cookie.cookie.state != Cookie.STATE.Unflipped:
			erased_cookies.erase(cookie)
			cookie.queue_free()
	#cookie_instances.clear()
	flip_button.text = "Flip"
	cookie_instances = erased_cookies
		

signal tutorial_exit
func _on_tutorial_exit_pressed() -> void:
	SoundManager.instance.play_sound("Click2", true)
	emit_signal("tutorial_exit")
	Globals.training = false
	if tutorial.instance != null:
		tutorial.instance.queue_free()
	UI.manager.remove_overlay(UI.NAME.Arena)

func _on_flip_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_flip_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
