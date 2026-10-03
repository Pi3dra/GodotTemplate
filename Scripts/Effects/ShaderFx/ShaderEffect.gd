class_name ShaderEffect
extends Effect

var shaderpath: String
var duration: float # negative = permanent: the material stays after the effect ends


func _init(p_shaderpath := "", p_duration := -1.0) -> void:
	shaderpath = p_shaderpath
	duration = p_duration


func _begin(run: EffectContext) -> void:
	var canvas := run.target as CanvasItem
	var shader := load(shaderpath) as Shader
	if canvas == null or shader == null:
		run.finish()
		return

	var mat := ShaderMaterial.new()
	mat.shader = shader
	run.data.previous_material = canvas.material # needed later by _cleanup
	canvas.material = mat
	run.data.material = mat

	if duration < 0.0:
		run.finish() # permanent: end now, leave the material on
		return

	run.finish_after(duration)


func _cleanup(run: EffectContext, _cancelled: bool) -> void:
	# Permanent shaders stay applied.
	if duration < 0.0:
		return

	var canvas := run.target as CanvasItem
	if not is_instance_valid(canvas):
		return

	# Only restore if our material is still the active one,
	# so we don't wipe a material applied by someone else in the meantime.
	if canvas.material == run.data.get("material"):
		canvas.material = run.data.get("previous_material")
