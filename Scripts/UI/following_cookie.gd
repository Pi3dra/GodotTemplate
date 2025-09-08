extends Control

var cookie : Cookie
var following := true

var up_tween : Tween
var flip_tween : Tween

@onready var texture_rect : TextureRect = $cookie_texture
@onready var shadow: TextureRect = $shadow
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var screen_middle : int

func _ready() -> void:
	texture_rect.texture = cookie.head_texture
	shadow.texture = load("uid://kc4ef7j3bwdl")
	var screen_size = get_viewport().get_visible_rect().size
	screen_middle = screen_size.x/2
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !following:
			following = true
		elif  event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and following and get_global_mouse_position().y > 200:
			following = false
			gpu_particles_2d.emitting = false

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
	# FLipping
	for i in range(5):
		flip_tween.tween_property(texture_rect, "scale:y", 0, duration)
		flip_tween.tween_callback(Callable(self, "_swap_side"))
		flip_tween.tween_property(texture_rect, "scale:y", 1, duration)
		duration += 0.02
	up_tween.tween_property(texture_rect, "position:y", texture_rect.position.y, 0.02*10 ) 
	#update_sprite()
	flip_tween.tween_callback(update_sprite)
	flip_tween.tween_callback(make_red)

## Change and emit particles for flip anim
func explo_particles():
	# ↓Save the default values
	var emitter: GPUParticles2D = gpu_particles_2d
	var base_one_shot := emitter.one_shot
	var base_explosiveness := emitter.explosiveness
	var base_lifetime := emitter.lifetime
	var base_preprocess := emitter.preprocess
	var base_emitting := emitter.emitting
	var base_mat := emitter.process_material as ParticleProcessMaterial
	var expl_mat := base_mat.duplicate(true) as ParticleProcessMaterial
	# ↓Change particles to be explosive
	expl_mat.initial_velocity_min = 115.0
	expl_mat.initial_velocity_max = 210.0
	emitter.one_shot = true
	emitter.explosiveness = 1.0
	emitter.lifetime = 1.0
	emitter.preprocess = 0.05
	emitter.process_material = expl_mat
	# ↓Start reliably
	emitter.restart()
	emitter.emitting = true
	# ↓Wait
	var timeout := get_tree().create_timer(emitter.lifetime + emitter.preprocess + 0.2)
	await timeout.timeout
	# ↓Restore base state
	emitter.emitting = false
	emitter.one_shot = base_one_shot
	emitter.explosiveness = base_explosiveness
	emitter.lifetime = base_lifetime
	emitter.preprocess = base_preprocess
	emitter.process_material = base_mat
	# ↓Force the emitter to reinitialize with the restored material/props
	emitter.restart()
	emitter.emitting = base_emitting

## Waits for the tween to stop to display the correct sprite + start particles
func update_sprite():
	if cookie.state == Cookie.STATE.Head:
		texture_rect.texture = cookie.head_texture
		explo_particles()
	elif cookie.state == Cookie.STATE.Tail :
		texture_rect.texture = cookie.tail_texture
		explo_particles()
		gpu_particles_2d.modulate = Color.RED

## Makes Cookie red when guessed wrong 
func make_red():
	await flip_tween.finished
	if cookie.state == Cookie.STATE.Tail:
		texture_rect.modulate = Color(1, 0, 0, 1)

func _swap_side():
	if texture_rect.texture == cookie.tail_texture:
		texture_rect.texture = cookie.head_texture
	elif texture_rect.texture == cookie.head_texture:
		texture_rect.texture = cookie.tail_texture


func _on_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.can_grab
	gpu_particles_2d.emitting = true
	
func _on_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
	gpu_particles_2d.emitting = false
	

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("l_click"):
		Cursor.instance.texture = Cursor.grab
	elif event.is_action_released("l_click"):
		Cursor.instance.texture = Cursor.can_grab

func animate_spawning():
	var texture = $cookie_texture
	
	# Ensure the pivot is at the center for Node2D, or adjust for Control nodes
	if texture is Node2D:
		texture.pivot_offset = texture.get_rect().size / 2
	elif texture is Control:
		texture.pivot_offset = texture.size / 2
	
	var tween = create_tween()
	tween.tween_property(texture, "scale", Vector2(1, 1), 0.4).from(Vector2(0, 0)).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
