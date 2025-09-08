extends BoxContainer

var button_cookies : Dictionary[Button,Cookie] = {}

func _ready() -> void:
	pass

func create_buttons(cookies : Array[Cookie]):
	for cookie in cookies:
		create_button(cookie)


func create_button(cookie):
		var button = Button.new()

		button.expand_icon = false
		
		# Create a StyleBoxTexture and assign the image
		var style = StyleBoxTexture.new()
		button.icon = cookie.head_texture
		
		# Apply StyleBox to normal, pressed, and hover states
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("pressed", style)
		button.add_theme_stylebox_override("hover", style)
		add_child(button)  # the BoxContainer will place it automatically
		
		button.button_down.connect(_on_button_down.bind(button))
		button.mouse_entered.connect(_on_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_mouse_exited.bind(button))
		button_cookies[button] = cookie
	

## Called when a child button is pressed
func _on_button_down(button):
	emit_signal("instantiate_cookie", button_cookies[button], button)
	
## This is called by parent to prevent pulling cookies on accept phase
func free_button(button):
	button.queue_free()
	
signal instantiate_cookie(cookie,button)


func _on_mouse_entered(pButton: Button = null) -> void:
	Engine.time_scale = 0.4
	AudioServer.playback_speed_scale = 0.4
	if pButton != null:
		pButton.pivot_offset = pButton.size/2
		var lTween = create_tween()
		lTween.tween_property(pButton, "scale", Vector2.ONE*2, 0.1)
		#TODO rajouter la fiche info des effets du cookie


func _on_mouse_exited(pButton: Button = null) -> void:
	Engine.time_scale = 1
	AudioServer.playback_speed_scale = 1
	if pButton != null:
		var lTween = create_tween()
		lTween.tween_property(pButton, "scale", Vector2.ONE*1, 0.1)
		#TODO enlever la fiche info des effets du cookie
