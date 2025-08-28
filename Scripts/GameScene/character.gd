extends  Node2D
 
signal attack(damage: int, team: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: ProgressBar = $LifeBar
@onready var animated_sprite_fx: AnimatedSprite2D = $AnimatedSpriteFX

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
					if has_been_crit == true: animated_sprite_fx.play("hit")
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
	var lTween_health = create_tween()
	character.health -= pDamage
	lTween_health.tween_property(life_bar,"value", character.health ,0.5)
	die()
	
