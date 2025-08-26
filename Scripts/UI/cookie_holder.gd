extends BoxContainer

var button_cookies : Dictionary[Button,Cookie] = {}

func _ready() -> void:
	pass

func create_buttons(cookies : Array[Cookie]):
	for cookie in cookies:
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
		
		button.pressed.connect(_on_button_pressed.bind(button))
		button_cookies[button] = cookie

## Called when a child button is pressed
func _on_button_pressed(button):
	emit_signal("instantiate_cookie", button_cookies[button], button)
	
## This is called by parent to prevent pulling cookies on accept phase
func free_button(button):
	button.queue_free()
	
signal instantiate_cookie(cookie,button)
