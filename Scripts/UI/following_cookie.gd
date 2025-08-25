extends Control

var cookie : Cookie
var following := true
var state : String

var up_tween : Tween
var flip_tween : Tween

@onready var texture_rect = $cookie_texture

func _ready() -> void:
	texture_rect.texture = cookie.head_texture


func _process(delta: float) -> void:
	if following:
		var mouse_pos = get_global_mouse_position()
		var new_pos = Vector2(mouse_pos.x - 16, mouse_pos.y - 16)
		position = new_pos


func flip_coin(npercent: int) -> String:
	# Clamp to 0–100 just in case
	npercent = clamp(npercent, 0, 100)
	
	var roll = randi() % 100 + 1
	if roll <= npercent:
		state = "HEAD"
	else:
		state = "TAIL"
	
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
	update()


	return state

func update():
	await flip_tween.finished
	if state == "HEAD":
		texture_rect.texture = cookie.head_texture
	elif state == "TAIL":
		texture_rect.texture = cookie.tail_texture
		
func make_red():
	await flip_tween.finished
	texture_rect.modulate = Color(1, 0, 0, 1)

func _swap_side():
	if texture_rect.texture == cookie.tail_texture:
		texture_rect.texture = cookie.head_texture
	elif texture_rect.texture == cookie.head_texture:
		texture_rect.texture = cookie.tail_texture
