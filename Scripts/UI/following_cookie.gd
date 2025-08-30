extends Control

var cookie : Cookie
var following := true

var up_tween : Tween
var flip_tween : Tween

@onready var texture_rect : TextureRect = $cookie_texture
@onready var shadow: TextureRect = $shadow

var screen_middle : int

func _ready() -> void:
	texture_rect.texture = cookie.head_texture
	shadow.texture = load("res://Assets/Sprites/cookie_shadow.png")
	var screen_size = get_viewport().get_visible_rect().size
	screen_middle = screen_size.x/2
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !following:
			following = true
		elif  event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and following and get_global_mouse_position().y > 200:
			print("Clicked:1")
			following = false
			if position.x < screen_middle:
				cookie.side = Cookie.SCREENSIDE.Head
			else:
				cookie.side = Cookie.SCREENSIDE.Tail

func _process(_delta: float) -> void:
	if following:
		var mouse_pos = get_global_mouse_position()
		var new_pos = Vector2(mouse_pos.x - 32, mouse_pos.y - 32)
		position = new_pos

func flip_coin(headpercent: int) -> Cookie.STATE:
	# Clamp to 0–100 just in case
	headpercent = clamp(headpercent, 0, 100)
	
	var roll = randi() % 100 + 1
	if roll <= headpercent:
		cookie.state = Cookie.STATE.Head
	else:
		cookie.state = Cookie.STATE.Tail
	
	do_flip_animation()
		
	return cookie.state
	
func do_flip_animation():
	flip_tween = get_tree().create_tween()
	up_tween = get_tree().create_tween()
	up_tween.set_ease(Tween.EASE_OUT_IN)
	up_tween.set_trans(Tween.TRANS_CUBIC)
	up_tween.tween_property(texture_rect, "position:y", texture_rect.position.y - 126, 0.02*10 )
	var duration = 0.02
	for i in range(5):
		flip_tween.tween_property(texture_rect, "scale:y", 0, duration)
		flip_tween.tween_callback(Callable(self, "_swap_side"))
		flip_tween.tween_property(texture_rect, "scale:y", 1, duration)
		duration += 0.02
	up_tween.tween_property(texture_rect, "position:y", texture_rect.position.y, 0.02*10 ) 
	update_sprite()

## Waits for the tween to stop to display the correct sprite
func update_sprite():
	await flip_tween.finished
	if cookie.state == Cookie.STATE.Head:
		texture_rect.texture = cookie.head_texture
	elif cookie.state == Cookie.STATE.Tail :
		texture_rect.texture = cookie.tail_texture

## Makes Cookie red when guessed wrong 
func make_red():
	await flip_tween.finished
	texture_rect.modulate = Color(1, 0, 0, 1)

func _swap_side():
	if texture_rect.texture == cookie.tail_texture:
		texture_rect.texture = cookie.head_texture
	elif texture_rect.texture == cookie.head_texture:
		texture_rect.texture = cookie.tail_texture
