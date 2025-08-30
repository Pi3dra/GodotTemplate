extends  Node2D
 
signal attack(damage: int, team: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: ProgressBar = $LifeBar
@onready var animated_sprite_fx: AnimatedSprite2D = $AnimatedSpriteFX
@onready var hit_damage: Label = $HitDamage
@onready var timer: Timer = $Timer

var scene_projectile = load("uid://deduo5msnlka4")

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
	if character.attack_speed != timer.wait_time:
		timer.wait_time = character.attack_speed
	emit_signal("attack", character.attack(), character.side, character.shooter, self) # arena gets it
#endregion


func attack_rate():
	timer.wait_time = character.attack_speed
	timer.timeout.connect(_on_attack_timer_timeout) # Pareil que lTimer.timout += _on_...


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


func shoot(pRival_pos: Vector2, pType):
	var lProjectile: Node2D = scene_projectile.instantiate()
	var lTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var lSprite: Sprite2D = lProjectile.get_child(0)
	add_child(lProjectile)
	
	match pType:
		character.TYPES.Cyclop:
			lSprite.texture = load("uid://bwwklxfbmpjk3")
			lSprite.flip_h
		character.TYPES.Wizard:
			lSprite.texture = load("uid://cjll7vd11gcj5")
		character.TYPES.Necromancer:
			lSprite.texture = load("uid://k1tqobuxqec")
		character.TYPES.Pixie:
			lSprite.texture = load("uid://clfd8c6pdss5l")
		character.TYPES.Ranger:
			lSprite.texture = load("uid://wvcuyen2nr6g")
		character.TYPES.Dragon:
			lSprite.texture = load("uid://b2h8juywe7h5p")
			lSprite.flip_h
		character.TYPES.Witch:
			lSprite.texture = load("uid://bqf1kgtep7uwx")
			lSprite.flip_h
	
	lTween.tween_property(lProjectile, "global_position", pRival_pos, 0.5).set
	lTween.tween_property(lProjectile, "modulate:a", 0, 0.6)
	lTween.set_parallel(false).tween_callback(projectile_finished.bind(lProjectile))

func projectile_finished(pProjectile: Node2D):
	pProjectile.queue_free()


func show_damage(pIs_Crit: bool, pDamage: float):
	var lLabel_damage = Label.new()
	add_child(lLabel_damage)
	
	lLabel_damage.text = str(pDamage as int)
	lLabel_damage.modulate = Color.ORANGE
	
	var lTween = create_tween()
	if pIs_Crit == false:
		lTween.tween_property(lLabel_damage, "position", Vector2(randf_range(15,-20),randf_range(-44,-52)), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		lTween.tween_property(lLabel_damage, "modulate", Color.TRANSPARENT, 0.2)
		lTween.tween_property(lLabel_damage, "position", Vector2.ZERO, 0.1)
		lTween.tween_callback(kill_tween.bind(lTween, lLabel_damage))
	else:
		animated_sprite_fx.play("hit")
		has_been_crit = false
		
		lLabel_damage.modulate = Color.RED
		lTween.set_parallel(true).tween_property(lLabel_damage, "position", Vector2(randf_range(15,-20),randf_range(-44,-52)), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		lTween.tween_property(lLabel_damage, "scale", Vector2(2.4,2.4), 0.4)
		lTween.set_parallel(false).tween_property(lLabel_damage, "modulate", Color.TRANSPARENT, 0.4)
		lTween.tween_property(lLabel_damage, "position", Vector2.ZERO, 0.1)
		lTween.tween_callback(kill_tween.bind(lTween, lLabel_damage))


func kill_tween(pTween: Tween, pLabel: Label):
	pLabel.queue_free()
	pTween.kill()

func no_attacking():
	timer.paused = true
	actual_state = States.WALKING

func attacking():
	timer.paused = false
	actual_state = States.IDLE
