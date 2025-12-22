extends BoxContainer

var button_cookies: Dictionary[Button, Cookie] = { }

var cookie_widgets := { } # { Cookie.TYPE: {"label": Label, "button": Button} }
var available_cookies: Dictionary #[Cookie.TYPE,int]
var placed_cookies: Array[Control] = []

var ui_root: Control
var cookie_tscn: PackedScene = load("uid://b5dekwm16iqx0")
var cookie_info_tscn: PackedScene = load("uid://dffxgoej8clrw")
@onready var cookie_container: ReferenceRect = $"../../CookieContainer"


func _ready() -> void:
	pass

#TODO: this could be further Refactored by separating
# CookiePanelManager
# CookieSpawner
# BarUI

#region Cookie Instantiation
func drop_cookie(cookie_type: Cookie.TYPE, pos):
	var cookie_instance = spawn_cookie(cookie_type)
	cookie_instance.position = pos
	cookie_instance.following = false
	cookie_instance.animate_spawning()


func spawn_cookie(cookie_type: Cookie.TYPE) -> Control:
	var cookie_instance = cookie_tscn.instantiate()
	var cookie_obj = Cookie.new(cookie_type)
	cookie_instance.cookie = cookie_obj
	cookie_instance.connect("return_cookie", _on_cookie_returned)
	placed_cookies.append(cookie_instance)
	ui_root.add_child(cookie_instance)
	return cookie_instance
#endregion

#region Cookie and Bar input
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


func _on_button_down(_button: Button, _label: Label, cookie: Cookie.TYPE) -> void:
	Cursor.instance.texture = Cursor.grab
	available_cookies[cookie] -= 1
	update_cookie_widget(cookie)
	var cookie_instance = spawn_cookie(cookie)

	await !cookie_instance.following
	if Cursor.instance.texture != Cursor.grab:
		Cursor.instance.texture = Cursor.basic


func _handle_bar_input(event, button, label, cookie):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_CTRL):
			_on_button_shift_click(button, label, cookie)
		elif Input.is_key_pressed(KEY_CTRL): # Ctrl + Click
			_on_button_ctrl_click(button, label, cookie)
		else: # Normal click
			_on_button_down(button, label, cookie)


func update_cookie_widget(cookie: Cookie.TYPE):
	var widget = cookie_widgets.get(cookie, null)
	if widget:
		widget.label.text = "  %dX" % available_cookies[cookie]
		widget.label.visible = available_cookies[cookie] > 0
		widget.button.visible = available_cookies[cookie] > 0


func update_cookie_bar():
	for cookie in available_cookies.keys():
		if available_cookies[cookie] > 0:
			add_to_bar(cookie)


func add_to_bar(cookie: Cookie.TYPE) -> void:
	if cookie_widgets.has(cookie):
		update_cookie_widget(cookie)
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

	add_child(label)
	add_child(button)

	# Save references
	cookie_widgets[cookie] = { "label": label, "button": button }
#endregion

#region Cookie Animation
func _end_of_return_animation(cookie_instance: Control):
	var cookie_object = cookie_instance.cookie
	var cookie_type = cookie_object.cookie_type
	placed_cookies.erase(cookie_instance)
	cookie_instance.queue_free()
	#TODO: This or update_cookie_widget?
	add_to_bar(cookie_type)


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


func _spawn_and_animate_cookie(
		button: Button,
		_label: Label,
		cookie: Cookie.TYPE,
		container_pos: Vector2,
		rect: Rect2,
		positions: Array = [],
) -> Vector2:
	available_cookies[cookie] -= 1
	update_cookie_widget(cookie)

	# Animation
	var cookie_instance = spawn_cookie(cookie)
	cookie_instance.position = button.global_position
	cookie_instance.texture_rect.scale = Vector2(0.5, 0.5)
	cookie_instance.following = false

	var random_pos = generate_random_pos(container_pos, rect, positions)
	_placement_animation(cookie_instance, random_pos)

	return random_pos
#endregion

#region Cookie placement
func _on_cookie_returned(cookie_instance: Control) -> void:
	var cookie_type = cookie_instance.cookie.cookie_type
	var cookie_texture = cookie_instance.texture_rect
	var return_tween = create_tween()
	available_cookies[cookie_type] = available_cookies.get(cookie_type, 0) + 1
	if not cookie_widgets.has(cookie_type):
		add_to_bar(cookie_type)

	var return_position = cookie_widgets[cookie_type]["button"].global_position

	#Making speed constant
	var duration = _calculate_duration(cookie_instance.position, return_position)

	return_tween.parallel().tween_property(cookie_instance, "position", return_position, duration)
	return_tween.parallel().tween_property(cookie_texture, "scale", Vector2(0.5, 0.5), duration)
	return_tween.tween_callback(_end_of_return_animation.bind(cookie_instance))


func _placement_animation(cookie_instance: Control, random_pos: Vector2) -> void:
	var cookie_texture = cookie_instance.texture_rect

	#Making speed constant
	var duration = _calculate_duration(cookie_instance.position, random_pos)

	var return_tween = create_tween()
	return_tween.parallel().tween_property(cookie_instance, "position", random_pos, duration)
	return_tween.parallel().tween_property(cookie_texture, "scale", Vector2(1, 1), duration)
#endregion

#region Random Position generation
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

#endregion

#region Information Panel
func show_cookie_infos(button: Button, cookie: Cookie.TYPE):
	#TODO this animation should be standalone
	Cursor.instance.texture = Cursor.can_grab
	var cookie_info_panel: Control = cookie_info_tscn.instantiate()
	var good_position: Vector2 = Vector2(30, 55)
	button.mouse_exited.connect(erase_panel.bind(cookie_info_panel, button))

	button.pivot_offset = button.size / 2
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2.ONE * 2, 0.1)
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(cookie_info_panel):
		Engine.time_scale = 0.4
		AudioServer.playback_speed_scale = 0.4
		ui_root.add_child(cookie_info_panel)
		cookie_info_panel.update_panel(cookie)
		cookie_info_panel.scale = Vector2.ZERO
		cookie_info_panel.global_position = button.global_position + good_position
		var tween_panel = create_tween()
		tween_panel.tween_property(cookie_info_panel, "scale", Vector2.ONE, 0.2)


func erase_panel(panel: Control, button):
	if Cursor.instance.texture != Cursor.grab:
		Cursor.instance.texture = Cursor.basic
	if is_instance_valid(panel):
		Engine.time_scale = 1
		AudioServer.playback_speed_scale = 1
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2.ONE * 1, 0.1)
		button.mouse_exited.disconnect(erase_panel.bind(panel, button))
		panel.queue_free()
#endregion
