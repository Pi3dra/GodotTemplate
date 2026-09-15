extends Effect
class_name ShaderEffect


# TODO Shader composition isn't yet supported, aThere are multiple approaches to chaining shaders
# the first one is to use next_pass on the shader Material
# the second and apparently the better one is to use subviewport chaining

var duration: float
var shaderpath : String

func _init(p_shaderpath : String, p_duration : float):
	duration = p_duration
	shaderpath = p_shaderpath


func execute(context: EffectContext) -> EffectHandle:
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = load(shaderpath)
	
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle
	
	target.material = shader_mat
	if duration == -1:
		handle.complete()
		return handle
	else:
		var tween := context.target.create_tween()
		tween.tween_interval(duration)
		tween.finished.connect(
			func():
				target.material = null
				handle.complete())


	return handle
