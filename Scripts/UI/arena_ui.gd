extends Control

var placed_cookies : Array [Control] = []
var active_cookies = Cookie.type_dict() #Dictionary[TYPE, Array[Cookie]]


@onready var flip_button: Button = $Flip
@onready var cookie_bar = $PanelContainer/CookieHolder
@onready var cookie_receiver : BoxContainer = $PanelContainer2/CookieHolder


func _ready() -> void:
	var available_cookies = UI.manager.get_data(UI.NAME.Arena)
	cookie_bar.available_cookies = available_cookies
	cookie_bar.ui_root = self
	cookie_bar.update_cookie_bar()
	
	#TODO Don't forget about this
	#UI.manager.connect_to_ui(UI.NAME.Arena,{"drop_cookie":drop_cookie})
	
	#hide()
	var tutorialbutton = $TutorialExit
	if Globals.training:
		tutorialbutton.show()
	else:
		tutorialbutton.hide()
	$Flip.position.y -= 120


#region FLIPPING COOKIES
signal combat_cookies(cookies: Array[Cookie], enemy: bool)
func _on_button_pressed() -> void:
	SoundManager.instance.play_sound("Click3", true, false)
	placed_cookies = cookie_bar.placed_cookies
	active_cookies = cookie_receiver.available_cookies
		
	if placed_cookies.size() < 1:
		return
	#### Handling pre flip Cookies
	var weighted_cookies = active_cookies.get(Cookie.TYPE.Weighted, 0)
	var head_chance = 0
	#for cookie in weighted_cookies:
	#	# TODO put this to 15
	#	if cookie.side == Cookie.SCREENSIDE.Head:
	#		head_chance += 25
	
	var head_cookies = active_cookies.get(Cookie.TYPE.Head, 0)
	head_chance += 15*head_cookies
	
	# TODO: Leave only weihgted cookie
	#var tail_cookies = active_cookies.get(Cookie.TYPE.Tail)
	#tail_chance += 30*tail_cookies.size()
	
	#### Cookie flipping
	var correct_guesses : Array[Control]
	var incorrect_guesses : Array[Control]

	for cookie_node in placed_cookies:
		var cookie_object : Cookie = cookie_node.cookie
		cookie_node.flip_coin(cookie_object.chance + head_chance)
		
		if cookie_object.state == Cookie.STATE.Head:
			correct_guesses.append(cookie_node)
		elif cookie_object.state == Cookie.STATE.Tail:
			incorrect_guesses.append(cookie_node)
		match cookie_object.cookie_type:
			Cookie.TYPE.Replay:
				if randf() > 0.5:
					cookie_bar.create_button(cookie_object)
	# Clear old effects:
	#active_cookies.clear()
	
	

	#if enemy_combat_cookie.size() > 0:
		#emit_signal("combat_cookies", enemy_combat_cookie, true)
	
	flip_button.disabled = true
	await get_tree().create_timer(2).timeout
	flip_button.disabled = false
	

	for cookie in correct_guesses:
		cookie_receiver._on_cookie_returned(cookie)
	for cookie in incorrect_guesses:
		cookie.disappearing_animation()
	placed_cookies.clear()
	
	if cookie_receiver.available_cookies.size() > 0:
		emit_signal("combat_cookies", active_cookies, false)
	
#endregion

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
