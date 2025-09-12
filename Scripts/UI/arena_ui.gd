extends Control

var cookie_tscn : PackedScene = load("uid://b5dekwm16iqx0")
var cookie_info_tscn: PackedScene = load("uid://dffxgoej8clrw")

var available_cookies : Dictionary[Cookie.TYPE,int] 
var placed_cookies : Array [Control] = []
var selected_cookie : Control

var active_cookies = Cookie.type_dict() #Dictionary[TYPE, Array[Cookie]]
var cookie_widgets := {} # { Cookie.TYPE: {"label": Label, "button": Button} }

@onready var flip_button: Button = $Flip
@onready var cookie_bar = $PanelContainer/CookieHolder
@onready var cookie_container: ReferenceRect = $ReferenceRect


func _ready() -> void:
	available_cookies = UI.manager.get_data(UI.NAME.Arena)
	update_cookie_bar()
	UI.manager.connect_to_ui(UI.NAME.Arena,{"drop_cookie":drop_cookie})
	
	#hide()
	var tutorialbutton = $TutorialExit
	if Globals.training:
		tutorialbutton.show()
	else:
		tutorialbutton.hide()
	$Flip.position.y -= 120
	
	if Globals.training and not Globals.already_trained:
		UI.manager.call_overlay(UI.NAME.Tutorial,self)

	
#region INPUT HANDLING
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and selected_cookie != null and get_global_mouse_position().y > 200:
			selected_cookie.following = false
			selected_cookie = null
			
func _handle_bar_input(event, button, label, cookie):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_CTRL):
			_on_button_shift_click(button, label, cookie)
		elif Input.is_key_pressed(KEY_CTRL): # Ctrl + Click
			_on_button_ctrl_click(button, label, cookie)
		else: # Normal click
			_on_button_down(button, label, cookie)

func overlaps_with_list(random_position, position_list) -> bool:
	var overlaps = false
	for pos in position_list:
		var distance = random_position.distance_to(pos)
		overlaps =  distance < 64
		if overlaps:
			break
	return overlaps
	
func generate_random_pos(container_pos, rect, list = []):
	var x = randf_range(container_pos.x, container_pos.x + rect.size.x - 64)
	var y = randf_range(container_pos.y, container_pos.y + rect.size.y - 64)
	var rpos = Vector2(x,y)
	var placed_positions = placed_cookies.map(func(cookie): return cookie.position)
	
	var overlaps = overlaps_with_list(rpos,placed_positions) or overlaps_with_list(rpos,list)
	
	if overlaps:
		return generate_random_pos(container_pos,rect,list)
	else:
		return rpos
	
func _spawn_and_animate_cookie(button: Button, label: Label, cookie: Cookie.TYPE, container_pos: Vector2, rect: Rect2, positions: Array = []) -> Vector2:
	available_cookies[cookie] -= 1
	label.text = "  " + str(available_cookies[cookie]) + "X"
	
	# Animation
	var cookie_instance = spawn_cookie(cookie)
	cookie_instance.position = button.global_position
	cookie_instance.texture_rect.scale = Vector2(0.5, 0.5)
	cookie_instance.following = false
	selected_cookie = null
	
	var random_pos = generate_random_pos(container_pos, rect, positions)
	_placement_animation(cookie_instance, random_pos)
	
	if available_cookies[cookie] < 1:
		label.hide()
		button.hide()
	return random_pos

func _on_button_ctrl_click(button: Button, label: Label, cookie: Cookie.TYPE) -> void:
	var rect = cookie_container.get_rect()
	var container_pos = cookie_container.global_position
	_spawn_and_animate_cookie(button, label, cookie, container_pos, rect)

func _on_button_shift_click(button: Button, label: Label, cookie: Cookie.TYPE) -> void:
	var positions = []
	var rect = cookie_container.get_rect()
	var container_pos = cookie_container.global_position
	for i in range(available_cookies[cookie]):
		var random_pos = _spawn_and_animate_cookie(button, label, cookie, container_pos, rect, positions)
		positions.append(random_pos)

func _on_button_down(button: Button, label: Label, cookie: Cookie.TYPE) -> void:
	available_cookies[cookie] -= 1
	label.text = "  " + str(available_cookies[cookie]) + "X"
	spawn_cookie(cookie)
	if available_cookies[cookie] < 1:
		label.hide()
		button.hide()
#endregion

#region cookie instantiation and animation
func _calculate_duration(origin: Vector2,end :Vector2, reference_distance := 400, target_duration := 0.3):
	var distance = origin.distance_to(end)
	var duration = target_duration * (distance / reference_distance)
	duration = max(duration, 0.05)  
	return duration
	

func _on_cookie_returned(cookie_instance: Control) -> void:
	var cookie_type = cookie_instance.cookie.cookie_type
	var cookie_texture = cookie_instance.texture_rect
	var return_tween = create_tween()
	var return_position = cookie_widgets[cookie_type]["button"].global_position
	
	#Making speed constant
	var duration = _calculate_duration(cookie_instance.position,return_position)
	
	return_tween.parallel().tween_property(cookie_instance, "position", return_position ,duration)
	return_tween.parallel().tween_property(cookie_texture, "scale", Vector2(0.5,0.5) ,duration)
	return_tween.tween_callback(_end_of_return_animation.bind(cookie_instance))
	
func _placement_animation(cookie_instance: Control, random_pos: Vector2) -> void:
	var cookie_texture = cookie_instance.texture_rect
	
	#Making speed constant
	var duration = _calculate_duration(cookie_instance.position, random_pos)
	
	var return_tween = create_tween()
	return_tween.parallel().tween_property(cookie_instance, "position", random_pos, duration)
	return_tween.parallel().tween_property(cookie_texture, "scale", Vector2(1,1), duration)
	
func _end_of_return_animation(cookie_instance : Control):
	var cookie_object = cookie_instance.cookie
	var cookie_type = cookie_object.cookie_type
	available_cookies[cookie_type] += 1
	placed_cookies.erase(cookie_instance)
	cookie_instance.queue_free()
	add_to_bar(cookie_type) 
	
func add_to_bar(cookie: Cookie.TYPE) -> void:
	if cookie_widgets.has(cookie):
		var label: Label = cookie_widgets[cookie]["label"]
		label.text = "  " + str(available_cookies[cookie]) + "X"
		label.show()
		
		var button: Button = cookie_widgets[cookie]["button"]
		button.show()
		return
	
	# Create new label + button
	var label = Label.new()
	label.text = "  " + str(available_cookies[cookie]) + "X"
	label.theme_type_variation = "Text"
	
	var style = StyleBoxTexture.new()
	
	var button = Button.new()
	button.icon = Globals.get_cookie_data(cookie).head_texture
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("hover", style)
	button.gui_input.connect(_handle_bar_input.bind(button, label, cookie))

	button.mouse_entered.connect(show_cookie_infos.bind(button, cookie))
	cookie_bar.add_child(label)
	cookie_bar.add_child(button)
	
	# Save references
	cookie_widgets[cookie] = {"label": label, "button": button}

func show_cookie_infos(pButton: Button, pCookie: Cookie.TYPE):
	var cookie_info_panel: Control = cookie_info_tscn.instantiate()
	var lGood_position: Vector2 = Vector2(30,55)
	pButton.mouse_exited.connect(erase_panel.bind(cookie_info_panel, pButton))
	
	pButton.pivot_offset = pButton.size/2
	var lTween = create_tween()
	lTween.tween_property(pButton, "scale", Vector2.ONE*2, 0.1)
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(cookie_info_panel):
		Engine.time_scale = 0.4
		AudioServer.playback_speed_scale = 0.4
		add_child(cookie_info_panel)
		cookie_info_panel.update_panel(pCookie)
		cookie_info_panel.scale = Vector2.ZERO
		cookie_info_panel.global_position = pButton.global_position + lGood_position
		var lTween_panel = create_tween()
		lTween_panel.tween_property(cookie_info_panel, "scale", Vector2.ONE, 0.2)
	
func erase_panel(panel:Control, pButton):
	if is_instance_valid(panel):
		Engine.time_scale = 1
		AudioServer.playback_speed_scale = 1
		var lTween = create_tween()
		lTween.tween_property(pButton, "scale", Vector2.ONE*1, 0.1)
		pButton.mouse_exited.disconnect(erase_panel.bind(panel, pButton))
		panel.queue_free()

func update_cookie_bar():
	for cookie in available_cookies.keys():
		if available_cookies[cookie] > 0:
			add_to_bar(cookie)

func spawn_cookie(cookie_type : Cookie.TYPE) -> Control:
	var cookie_instance = cookie_tscn.instantiate()
	var cookie_obj = Cookie.new(cookie_type)
	cookie_instance.cookie = cookie_obj
	cookie_instance.connect("return_cookie", _on_cookie_returned)
	placed_cookies.append(cookie_instance)
	selected_cookie = cookie_instance
	add_child(cookie_instance)
	return cookie_instance

func drop_cookie(cookie_type: Cookie.TYPE, pos):
	var cookie_instance = spawn_cookie(cookie_type)
	cookie_instance.position = pos
	cookie_instance.following = false
	selected_cookie = null
	cookie_instance.animate_spawning()

#endregion

#region FLIPPING COOKIES
signal combat_cookies(cookies: Array[Cookie], enemy: bool)
func _on_button_pressed() -> void:
	SoundManager.instance.play_sound("Click3", true, false)
	if flip_button.text == "Flip":
		
		if placed_cookies.size() < 1:
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
	var erased_cookies = placed_cookies.duplicate()
	for cookie in placed_cookies:
		if cookie.cookie.state != Cookie.STATE.Unflipped:
			erased_cookies.erase(cookie)
			cookie.queue_free()
	#cookie_instances.clear()
	flip_button.text = "Flip"
	placed_cookies = erased_cookies

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
