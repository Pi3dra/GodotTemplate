class_name ShaderEffect
extends Effect

var duration: float
var shaderpath: String
var _canvas: CanvasItem


func _init(p_shaderpath: String, p_duration: float) -> void:
	shaderpath = p_shaderpath
	duration = p_duration


func _start() -> Tween:
	_canvas = target as CanvasItem
	if _canvas == null:
		return null

	var mat := ShaderMaterial.new()
	mat.shader = load(shaderpath)
	_canvas.material = mat

	if duration < 0:
		return null # permanent: finish now, leave the material on

	var tween := _canvas.create_tween()
	tween.tween_interval(duration)
	return tween


func _cleanup(_cancelled: bool) -> void:
	# Permanent shaders (duration < 0) stay applied.
	if duration >= 0 and is_instance_valid(_canvas):
		_canvas.material = null
