extends Effect

class_name TextParticle

var text: String
var duration: float
var strength: float
var origin: Vector2
var effect: Effect


func _init(
		p_text: String,
		p_duration: float,
		p_strength: float,
		p_effect: Effect,
		pos: Vector2,
) -> void:
	text = p_text
	duration = p_duration
	strength = p_strength
	origin = pos
	effect = p_effect


func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var new_label := RichTextLabel.new()
	new_label.bbcode_enabled = true
	new_label.fit_content = true
	new_label.text = text

	# Important for a dynamically created RichTextLabel
	new_label.custom_minimum_size = Vector2(150, 40)
	new_label.size = Vector2(150, 40)

	new_label.add_theme_font_size_override("normal_font_size", 24)
	new_label.position = origin

	target.add_child(new_label)

	if effect != null:
		effect.play(new_label)

	# Random direction, biased upward
	var angle := randf_range(
		deg_to_rad(220),
		deg_to_rad(320),
	)
	var distance := randf_range(60.0, 90.0) * strength
	var direction := Vector2(
		cos(angle),
		sin(angle),
	)
	var target_position := new_label.position + direction * distance

	var tween := target.create_tween()
	tween.tween_property(
		new_label,
		"position",
		target_position,
		0.5,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_callback(
		func():
			handle.complete()
			new_label.queue_free()
	)

	return handle
