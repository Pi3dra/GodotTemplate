extends Node2D

signal attack(damage: int, team: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_bar: ProgressBar = $VBoxContainer/LifeBar
@onready var animated_sprite_fx: AnimatedSprite2D = $AnimatedSpriteFX
@onready var hit_damage: Label = $HitDamage
@onready var timer: Timer = $Timer
@onready var attack_bar: ProgressBar = $VBoxContainer/AttackTime

var scene_projectile = load("uid://deduo5msnlka4")
var font_theme = load("uid://dasqtqhyfj758")

enum States { IDLE, WALKING, ATTACKING, DYING, HURT }
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
				if character.side == LogicalCharacter.SIDE.GOOD:
					SoundManager.instance.play_sound("Attack1", true, true)
				else:
					SoundManager.instance.play_sound("Attack2", true, true)
				animated_sprite.play("attack")
			States.DYING:
				var tween_die = create_tween()
				tween_die.tween_property(animated_sprite, "modulate", Color.TRANSPARENT, 0.8)
				animated_sprite_fx.play("die")
				animated_sprite.play("die")
				SoundManager.instance.play_sound("Death", true, true)
			States.HURT:
				animated_sprite.play("hit")

var character: LogicalCharacter

var has_been_crit: bool = false


#//////////function//////////
func _ready() -> void:
	animated_sprite = get_child(0) as AnimatedSprite2D # Because it's AnimSprite2D is the only child
	animated_sprite.sprite_frames = character.sprite_frame
	actual_state = States.WALKING
	life_bar.max_value = character.total_health
	character.char_instance = self
	attack_rate()


func update_lifebar():
	life_bar.value = character.health
	life_bar.max_value = character.health

#region Signals
func _on_animated_sprite_2d_animation_finished() -> void:
	if previous_state == States.DYING:
		queue_free() # To kill this mtf
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
	if previous_state == States.DYING:
		return # To avoid bug where attack can be done dying
	var attack_info: Array = character.attack()
	if character.attack_speed != timer.wait_time:
		timer.wait_time = character.attack_speed
	emit_signal("attack", attack_info, character.side, character.shooter, self) # arena gets it

	start_attack_bar()
#endregion

func attack_rate():
	timer.wait_time = character.attack_speed
	timer.timeout.connect(_on_attack_timer_timeout)
	start_attack_bar()


var bar_tween: Tween


func start_attack_bar():
	if bar_tween != null:
		bar_tween.kill()
	attack_bar.value = 0
	attack_bar.max_value = character.attack_speed
	bar_tween = create_tween()
	bar_tween.tween_property(attack_bar, "value", character.attack_speed, timer.wait_time)


func die():
	if character.health <= 0:
		#faire le trala
		actual_state = States.DYING


# This is called in arena
func receive_damage(damage, crit):
	actual_state = States.HURT
	show_damage(crit, damage) # Anim numb damage
	character.health -= damage
	animate_health_bar()
	die()


func animate_health_bar():
	var tween_health = create_tween()
	tween_health.tween_property(life_bar, "value", character.health, 0.5)


func shoot(rival_pos: Vector2, type):
	var projectile: Node2D = scene_projectile.instantiate()
	var tween = create_tween()
	tween.set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var sprite: Sprite2D = projectile.get_child(0)
	add_child(projectile)

	var char_data = Globals.get_character_data(type)
	sprite.texture = char_data.projectile
	sprite.flip_h = char_data.side == LogicalCharacter.SIDE.BAD

	tween.tween_property(projectile, "global_position", rival_pos, 0.5)
	tween.tween_property(projectile, "modulate:a", 0, 0.6)
	tween.set_parallel(false).tween_callback(projectile_finished.bind(projectile))


func projectile_finished(projectile: Node2D):
	projectile.queue_free()


func show_damage(is_crit: bool, damage: float, healing := false):
	var label_damage := Label.new()
	add_child(label_damage)

	# Color depending on healing / crit
	if healing:
		label_damage.modulate = Color.GREEN
	else:
		label_damage.modulate = Color.RED if is_crit else Color.ORANGE

	label_damage.theme = font_theme
	label_damage.position = Vector2.ZERO
	label_damage.scale = Vector2.ONE

	# Animate the number (0 → pDamage)
	var tween_num := create_tween()
	tween_num.tween_method(
		func(value):
			label_damage.text = str(int(round(value))),
		0.0,
		damage,
		1.0,
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Animate position + fade
	var tween_fx := create_tween()

	if not is_crit:
		tween_fx.tween_property(
			label_damage,
			"position",
			Vector2(randf_range(-20, 15), randf_range(-52, -44)),
			0.5,
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		tween_fx.tween_property(
			label_damage,
			"modulate",
			Color.TRANSPARENT,
			0.2,
		).set_delay(1.0)
	else:
		animated_sprite_fx.play("hit")
		has_been_crit = false

		tween_fx.set_parallel(true).tween_property(
			label_damage,
			"position",
			Vector2(randf_range(-20, 15), randf_range(-52, -44)),
			0.5,
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		tween_fx.tween_property(
			label_damage,
			"scale",
			Vector2(2.4, 2.4),
			0.4,
		)

		tween_fx.set_parallel(false).tween_property(
			label_damage,
			"modulate",
			Color.TRANSPARENT,
			0.4,
		).set_delay(1.0)

	tween_fx.tween_callback(label_damage.queue_free)


func kill_tween(tween: Tween, label: Label):
	label.queue_free()
	tween.kill()


func no_attacking():
	timer.paused = true
	actual_state = States.WALKING


func attacking():
	timer.paused = false
	actual_state = States.IDLE
