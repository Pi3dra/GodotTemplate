extends  Node2D
 
signal attack(damage: int, team: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: ProgressBar = $LifeBar

var character : LogicalCharacter 


#//////////function//////////
func _ready() -> void:
	animated_sprite = get_child(0) as AnimatedSprite2D # Because it's AnimSprite2D is the only child
	animated_sprite.sprite_frames = load(character.sprite_frame) as SpriteFrames # Load accordingly to the logical character
	animated_sprite.play("idle")
	
	life_bar.max_value = character.health
	
	attack_rate()


func _process(delta: float) -> void:
	pass


func attack_rate():
	var lTimer = Timer.new()
	lTimer.autostart = true
	lTimer.one_shot = false
	lTimer.wait_time = character.attack_speed
	lTimer.timeout.connect(_on_attack_timer_timeout) # Pareil que lTimer.timout += _on_...
	add_child(lTimer)


func _on_attack_timer_timeout():
	emit_signal("attack", character.damage, character.side)


func die():
	if character.health <= 0:
		#faire le trala
		queue_free()


func receive_damage(damage):
	var health_tween = create_tween()
	character.health -= damage
	health_tween.tween_property(life_bar,"value", character.health ,0.5)
	die()
