extends BoxContainer

# TODO make the parent do this
func _ready():
	for i in range(5):
		var btn = Button.new()
		#btn.text = "c"
		btn.expand_icon = false
		#btn.rect_min_size = Vector2(32, 32)
		
		# Create a StyleBoxTexture and assign the image
		var style = StyleBoxTexture.new()
		btn.icon = load("res://Assets/Sprites/Head.png")

		
		# Apply StyleBox to normal, pressed, and hover states
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("hover", style)
		add_child(btn)  # the BoxContainer will place it automatically
		btn.pressed.connect(_on_button_pressed.bind(btn))

func _on_button_pressed(btn):
	btn.queue_free()
	emit_signal("instantiate_cookie", btn.text)
	
signal instantiate_cookie(cookie)
