extends Control

class_name CookieSelectUI

static var instance

@onready var cookie_bar: HBoxContainer = $VBoxContainer/PanelContainer/CookierBar
@onready var accept_button: Button = $Accept
@onready var cookie_container: Panel = $VBoxContainer/Panel

var available_cookies: Dictionary[Cookie.TYPE, int] = { }

var selected_cookie
var placed_cookies: Array #Cookie nodes

var cookie_tscn: PackedScene = load("uid://b5dekwm16iqx0")
var cookie_widgets := { } # { Cookie.TYPE: {"label": Label, "button": Button} }


func _ready():
	available_cookies = UI.manager.get_data(UI.NAME.COOKIE_SELECTION)
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
	label.theme_type_variation = "TextBox"

	var style = StyleBoxTexture.new()

	var button = Button.new()
	button.icon = Globals.get_cookie_data(cookie).head_texture
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("hover", style)
	button.gui_input.connect(_handle_bar_input.bind(button, label, cookie))

	cookie_bar.add_child(label)
	cookie_bar.add_child(button)

	# Save references
	cookie_widgets[cookie] = { "label": label, "button": button }


func _handle_bar_input(event, button, label, cookie):
	if placed_cookies.size() > 0:
		accept_button.disabled = false
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
		overlaps = distance < 64
		if overlaps:
			break
	return overlaps


func generate_random_pos(container_pos, rect, list = []):
	var x = randf_range(container_pos.x, container_pos.x + rect.size.x - 64)
	var y = randf_range(container_pos.y, container_pos.y + rect.size.y - 64)
	var rpos = Vector2(x, y)
	var placed_positions = placed_cookies.map(func(cookie): return cookie.position)

	var overlaps = overlaps_with_list(rpos, placed_positions) or overlaps_with_list(rpos, list)

	if overlaps:
		return generate_random_pos(container_pos, rect, list)
	return rpos


func _spawn_and_animate_cookie(
		button: Button,
		label: Label,
		cookie: Cookie.TYPE,
		container_pos: Vector2,
		rect: Rect2,
		positions: Array = [],
) -> Vector2:
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
		var random_pos = _spawn_and_animate_cookie(
			button,
			label,
			cookie,
			container_pos,
			rect,
			positions,
		)
		positions.append(random_pos)


func _on_button_down(button: Button, label: Label, cookie: Cookie.TYPE) -> void:
	available_cookies[cookie] -= 1
	label.text = "  " + str(available_cookies[cookie]) + "X"
	spawn_cookie(cookie)
	if available_cookies[cookie] < 1:
		label.hide()
		button.hide()


func update_cookie_bar():
	for cookie in available_cookies.keys():
		if available_cookies[cookie] > 0:
			add_to_bar(cookie)


func spawn_cookie(cookie_type: Cookie.TYPE) -> Control:
	var cookie_instance = cookie_tscn.instantiate()
	var cookie_obj = Cookie.new(cookie_type)
	cookie_instance.cookie = cookie_obj
	cookie_instance.connect("return_cookie", _on_cookie_returned)
	placed_cookies.append(cookie_instance)
	selected_cookie = cookie_instance
	add_child(cookie_instance)
	return cookie_instance


func _calculate_duration(
		origin: Vector2,
		end: Vector2,
		reference_distance := 400,
		target_duration := 0.3,
):
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
	var duration = _calculate_duration(cookie_instance.position, return_position)

	return_tween.parallel().tween_property(cookie_instance, "position", return_position, duration)
	return_tween.parallel().tween_property(cookie_texture, "scale", Vector2(0.5, 0.5), duration)
	return_tween.tween_callback(_end_of_return_animation.bind(cookie_instance))

	if placed_cookies.size() - 1 < 1:
		accept_button.disabled = true


func _placement_animation(cookie_instance: Control, random_pos: Vector2) -> void:
	var cookie_texture = cookie_instance.texture_rect

	#Making speed constant
	var duration = _calculate_duration(cookie_instance.position, random_pos)

	var return_tween = create_tween()
	return_tween.parallel().tween_property(cookie_instance, "position", random_pos, duration)
	return_tween.parallel().tween_property(cookie_texture, "scale", Vector2(1, 1), duration)


func _end_of_return_animation(cookie_instance: Control):
	var cookie_object = cookie_instance.cookie
	var cookie_type = cookie_object.cookie_type
	available_cookies[cookie_type] += 1
	placed_cookies.erase(cookie_instance)
	cookie_instance.queue_free()
	add_to_bar(cookie_type)


func _on_exit_pressed() -> void:
	SoundManager.instance.play_sound("Click2", true, false)
	#TODO: restart the selected battle
	UI.manager.remove_overlay(UI.NAME.COOKIE_SELECTION)


signal selected_cookie_deck(cookies)


func _on_accept_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	var chosen_cookies: Array = placed_cookies.map(
		func(cookie_node): return cookie_node.cookie.cookie_type
	)
	var counted_cookies: Dictionary[Cookie.TYPE, int] = { }
	for cookie in chosen_cookies:
		counted_cookies.set(cookie, counted_cookies.get_or_add(cookie, 0) + 1)
	emit_signal("selected_cookie_deck", counted_cookies)
	UI.manager.remove_overlay(UI.NAME.COOKIE_SELECTION)


func _on_exit_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_exit_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic


func _on_accept_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_accept_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
