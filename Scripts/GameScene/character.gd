extends  Node2D
 
signal attack(damage: int, team: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: ProgressBar = $LifeBar

enum States {IDLE, WALKING, ATTACKING, DYING, HURT}

# This variable keeps track of the character's current state.
var actual_state: States = States.IDLE:
	set(pNew_state):
		var previous_state: States = actual_state
		actual_state = pNew_state as States
		match actual_state:
				States.IDLE:
					animated_sprite.play("idle")
				States.WALKING:
					animated_sprite.play("walk")
				States.ATTACKING:
					animated_sprite.play("attack")
				States.DYING:
					animated_sprite.play("die")
				States.HURT:
					animated_sprite.play("hit")

var character : LogicalCharacter 


#//////////function//////////
func _ready() -> void:
	animated_sprite = get_child(0) as AnimatedSprite2D # Because it's AnimSprite2D is the only child
	animated_sprite.sprite_frames = load(character.sprite_frame) as SpriteFrames # Load accordingly to the logical character
	
	actual_state = States.WALKING
	
	life_bar.max_value = character.health
	
	attack_rate()


func attack_rate():
	var lTimer = Timer.new()
	lTimer.autostart = true
	lTimer.one_shot = false
	lTimer.wait_time = character.attack_speed
	lTimer.timeout.connect(_on_attack_timer_timeout) # Pareil que lTimer.timout += _on_...
	add_child(lTimer)

func _on_attack_timer_timeout():
	actual_state = States.ATTACKING
	crit()
	emit_signal("attack", character.attack(), character.side) # arena gets it


func die():
	if character.health <= 0:
		#faire le trala
		actual_state = States.DYING
		queue_free()


func crit():
	randomize()
	var lCrit_chance: float = character.crit
	if lCrit_chance >= randf_range(0,1):
		character.damage += character.damage/2


# This is called in arena
func receive_damage(damage):
	actual_state = States.HURT
	var health_tween = create_tween()
	character.health -= damage
	health_tween.tween_property(life_bar,"value", character.health ,0.5)
	die()
