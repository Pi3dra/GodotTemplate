extends  Node2D
 
signal attack(damage: int, team: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: ProgressBar = $LifeBar
@onready var animated_sprite_fx: AnimatedSprite2D = $AnimatedSpriteFX
@onready var hit_damage: Label = $HitDamage

enum States {IDLE, WALKING, ATTACKING, DYING, HURT}

var previous_state: States

# This variable keeps track of the character's current state.
var actual_state: States = States.IDLE:
	set(pNew_state):
		previous_state = actual_state
		actual_state = pNew_state as States
		match actual_state:
				States.IDLE:
					animated_sprite.play("idle")
				States.WALKING:
					animated_sprite.play("walk")
				States.ATTACKING:
					animated_sprite.play("attack")
				States.DYING:
					var lTween_die = create_tween()
					lTween_die.tween_property(animated_sprite, "modulate", Color.TRANSPARENT, 0.8)
					animated_sprite_fx.play("die")
					animated_sprite.play("die")
				States.HURT:
					if has_been_crit == true:
						animated_sprite_fx.play("hit")
						has_been_crit = false
					animated_sprite.play("hit")


var character : LogicalCharacter 

var has_been_crit: bool = false


#//////////function//////////
func _ready() -> void:
	animated_sprite = get_child(0) as AnimatedSprite2D # Because it's AnimSprite2D is the only child
	animated_sprite.sprite_frames = load(character.sprite_frame) as SpriteFrames # Load accordingly to the logical character
	
	actual_state = States.WALKING
	
	life_bar.max_value = character.health
	
	attack_rate()


func _process(delta: float) -> void:
	pass


#region Signals
func _on_animated_sprite_2d_animation_finished() -> void:
	if previous_state == States.DYING: queue_free() # To kill this mtf
	match actual_state:
			States.WALKING:
				actual_state = States.IDLE
			States.ATTACKING:
				actual_state = States.IDLE
			States.HURT:
				actual_state = States.IDLE
			States.DYING:
				queue_free()


func _on_attack_timer_timeout():
	actual_state = States.ATTACKING
	if previous_state == States.DYING: return # To avoid bug where attack can be done dying
	var attack_info : Array = character.attack()
	emit_signal("attack", character.attack(), character.side) # arena gets it
#endregion


func attack_rate():
	var lTimer = Timer.new()
	lTimer.autostart = true
	lTimer.one_shot = false
	lTimer.wait_time = character.attack_speed
	lTimer.timeout.connect(_on_attack_timer_timeout) # Pareil que lTimer.timout += _on_...
	add_child(lTimer)


func die():
	if character.health <= 0:
		#faire le trala
		actual_state = States.DYING


# This is called in arena
func receive_damage(pDamage, pCrit):
	actual_state = States.HURT
	if pCrit == true: has_been_crit = true
	show_damage(has_been_crit, pDamage) # Anim numb damage
	var lTween_health = create_tween()
	character.health -= pDamage
	lTween_health.tween_property(life_bar, "value", character.health ,0.5)
	die()


func show_damage(pIs_Crit: bool, pDamage: float):
	var lPos_array: Array[Vector2] = [Vector2(10,-45), Vector2(-5,-52), Vector2(-20,-47)]
	
	hit_damage.text = str(pDamage as int)
	hit_damage.modulate = Color.ORANGE
	
	if pIs_Crit == false:
		var lTween = create_tween()
		lTween.tween_property(hit_damage, "position", lPos_array.pick_random(), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		lTween.tween_property(hit_damage, "modulate", Color.TRANSPARENT, 0.2)
		lTween.tween_property(hit_damage, "position", Vector2.ZERO, 0.1)
		lTween.tween_callback(kill_tween.bind(lTween))
	else:
		hit_damage.modulate = Color.RED
		var lTween = create_tween().set_parallel(true)
		lTween.tween_property(hit_damage, "position", lPos_array.pick_random(), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		lTween.tween_property(hit_damage, "theme_override_font_sizes/font_size", 100.0, 0.5)
		lTween.set_parallel(false).tween_property(hit_damage, "modulate", Color.TRANSPARENT, 0.2)
		lTween.tween_property(hit_damage, "position", Vector2.ZERO, 0.1)
		lTween.tween_callback(kill_tween.bind(lTween))


func kill_tween(pTween: Tween):
	hit_damage.add_theme_font_size_override("font_size", 16)
	pTween.kill()
