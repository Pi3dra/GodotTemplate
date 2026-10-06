class_name TextParticle
extends Effect

@export var text: String
@export var duration: float
@export var strength: float
@export var origin: Vector2
@export var effect: Effect
@export var parent_mode: Effect.Parent


func _init(
		p_text: String,
		p_duration: float,
		p_strength: float,
		p_effect: Effect,
		pos: Vector2,
		p_parent: Effect.Parent,
) -> void:
	text = p_text
	duration = p_duration
	strength = p_strength
	origin = pos
	effect = p_effect
	parent_mode = p_parent


func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return

	var label = create_label(text)
	run.spawn(label, parent_mode, get_center(target))

	if effect != null:
		var new_effect = EffectContext.new(effect, target)
		run.data.child = new_effect
		new_effect.start()

	run.use_tween(animation_tween(label, run.target))


func create_label(label_text: String) -> RichTextLabel:
	var new_label := RichTextLabel.new()
	new_label.bbcode_enabled = true
	new_label.fit_content = true
	new_label.text = label_text

	# Important for a dynamically created RichTextLabel
	new_label.custom_minimum_size = Vector2(150, 40)
	new_label.size = Vector2(150, 40)

	new_label.add_theme_font_size_override("normal_font_size", 24)

	return new_label


func animation_tween(label: RichTextLabel, target) -> Tween:
	var angle := randf_range(
		deg_to_rad(220),
		deg_to_rad(320),
	)
	var distance := randf_range(60.0, 90.0) * strength
	var direction := Vector2(
		cos(angle),
		sin(angle),
	)
	var target_position := label.position + direction * distance

	var tween: Tween = target.create_tween()
	tween.tween_property(
		label,
		"position",
		target_position,
		0.5,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	return tween


func _cleanup(run: EffectContext, _cancelled: bool) -> void:
	var child := run.data.get("child") as EffectContext
	if child:
		child.cancel() # no-op if it already finished
