extends BoxContainer

# TODO make the parent do this
var button_cookies = {}

func _ready() -> void:
	pass

func create_buttons(cookies : Array[Cookie]):
	for cookie in cookies:
		var btn = Button.new()
		#btn.text = "c"
		btn.expand_icon = false
		#btn.rect_min_size = Vector2(32, 32)
		
		# Create a StyleBoxTexture and assign the image
		var style = StyleBoxTexture.new()
		btn.icon = cookie.head_texture
		
		# Apply StyleBox to normal, pressed, and hover states
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("hover", style)
		add_child(btn)  # the BoxContainer will place it automatically
		btn.pressed.connect(_on_button_pressed.bind(btn))
		button_cookies[btn] = cookie

func _on_button_pressed(btn):
	btn.queue_free()
	emit_signal("instantiate_cookie", button_cookies[btn])
	
signal instantiate_cookie(cookie)
