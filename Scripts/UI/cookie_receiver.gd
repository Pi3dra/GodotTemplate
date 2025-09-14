extends BoxContainer

var cookie_widgets := {} # { Cookie.TYPE: {"label": Label, "button": Button} }
var available_cookies : Dictionary #[Cookie.TYPE,int] 

@onready var shaker: SimpleShaker = $"../../Shaker"

func _ready() -> void:
	if shaker != null:
		shaker._targets.append($"..")

func update_cookie_widget(cookie: Cookie.TYPE):
	var widget = cookie_widgets.get(cookie, null)
	if widget:
		var label: RichTextLabel = widget.label
		label.clear()
		label.add_image(Globals.get_cookie_data(cookie).head_texture)
		label.append_text("x%d  " % available_cookies[cookie])
		label.visible = available_cookies[cookie] > 0

func erase_cookie(cookie_type):
	if cookie_widgets.has(cookie_type):
		cookie_widgets[cookie_type]["label"].hide()

func update_cookie_bar():
	for cookie in available_cookies.keys():
		if available_cookies[cookie] > 0:
			add_to_bar(cookie)

func add_to_bar(cookie: Cookie.TYPE) -> void:
	if cookie_widgets.has(cookie):
		update_cookie_widget(cookie)
		return
	
	# Create a RichTextLabel
	var cookie_data = Globals.get_cookie_data(cookie)
	var richlabel = RichTextLabel.new()
	richlabel.bbcode_enabled = true
	richlabel.fit_content = true
	richlabel.scroll_active = false
	richlabel.clip_contents = false
	richlabel.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Register the cookie texture as an inline image
	richlabel.add_image(cookie_data.head_texture)
	richlabel.append_text("x%d  " % available_cookies[cookie])

	add_child(richlabel)
	
	# Save references
	cookie_widgets[cookie] = {"label": richlabel}
#endregion

#region Cookie Animation
func _end_of_return_animation(cookie_instance : Control):
	var cookie_object = cookie_instance.cookie
	var cookie_type = cookie_object.cookie_type
	cookie_instance.queue_free()
	shaker.start()
	#TODO: This or update_cookie_widget? 
	add_to_bar(cookie_type) 
	
func _calculate_duration(origin: Vector2,end :Vector2, reference_distance := 400, target_duration := 0.3):
	var distance = origin.distance_to(end)
	var duration = target_duration * (distance / reference_distance)
	duration = max(duration, 0.05)  
	return duration
	
#endregion

#region Cookie placement
func _on_cookie_returned(cookie_instance: Control) -> void:
	var cookie_type = cookie_instance.cookie.cookie_type
	var cookie_texture = cookie_instance.texture_rect
	
	available_cookies[cookie_type] = available_cookies.get(cookie_type,0) + 1
	
	var is_new = false
	if not cookie_widgets.has(cookie_type):
		add_to_bar(cookie_type)
		is_new = true

	#This works, but it hurts me deeply
	#Containers sort their children
	# - When a change is detected
	# - When the change detected is from a visible children (not hidden)
	# So we have to add the buttons as visible, wait for the container to position them
	# correctly and emit it's signal, then hide them for the time the cookies get to the bar
	# this is only needed for new cookies, as already existing cookies will rarely emit sort_children
	
	if is_new:
		await self.sort_children

	var return_position = cookie_widgets[cookie_type]["label"].global_position

	if is_new:
		cookie_widgets[cookie_type]["label"].hide()
	
	#Making speed constant
	var duration = _calculate_duration(cookie_instance.position,return_position)
	
	print("tweening")
	var return_tween = create_tween()
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
#endregion 
