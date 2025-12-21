extends Node

class_name SimpleShaker

@export_group("Targets")
@export var _targets: Array[Node] = []

@export_group("General")
@export var duration: float = 2.0
@export var amplitude: Vector2 = Vector2.ONE * 5.0
@export_range(0, 1, 0.001, "or_greater") var step: float = 0.048
@export_range(0, 30, 0.1, "radians_as_degrees") var noise: float = 15.0
@export var inverse_control_nodes: bool = false

@export_group("Attack")
@export var transition_attack: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_attack: Tween.EaseType = Tween.EASE_IN_OUT
@export var duration_attack: float = 0.25

@export_group("Release")
@export var transition_release: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_release: Tween.EaseType = Tween.EASE_IN_OUT
@export var duration_release: float = 0.25

var current: Vector2
var next: Vector2
var targets: Array[Node] = []
var origins: Array[Vector2] = []

var amplitude_max: float
var current_amplitude: Vector2

var shake: Tween
var loop: Tween
var intensity: float = 0.0

var random := RandomNumberGenerator.new()


func _ready():
	random.randomize()


func start():
	stop()
	amplitude = amplitude.abs()
	amplitude_max = max(amplitude.x, amplitude.y)
	current = Vector2.from_angle(PI * 2 * random.randf()) * amplitude_max

	targets.clear()
	origins.clear()

	print(_targets)
	for t in _targets:
		if t is Node2D or t is Control:
			targets.append(t)
		else:
			print(name + ": " + str(t.name) + " n'est pas un Node2D ou Control et sera ignoré.")

	if targets.is_empty():
		print("Aucune cible du Shake, start() ignoré.")
		return

	for t in targets:
		origins.append(t.position)

	intensity = 0.0

	shake = create_tween()
	shake.tween_property(self, "intensity", 1.0, duration_attack).set_trans(transition_attack).set_ease(ease_attack)
	shake.tween_interval(duration)
	shake.tween_property(self, "intensity", 0.0, duration_release).set_trans(transition_release).set_ease(ease_release)
	shake.finished.connect(stop)

	loop_func()


func stop():
	if targets.is_empty():
		return
	for i in range(targets.size()):
		targets[i].position = origins[i]

	if loop:
		loop.kill()
	if shake:
		shake.kill()
	shake = null


func is_playing() -> bool:
	return shake != null


func loop_func():
	next = -Vector2.from_angle(current.angle() + deg_to_rad(random.randf_range(-noise, noise))) * amplitude_max

	if amplitude.x < amplitude_max and abs(next.x) > amplitude.x:
		next.x = sign(next.x) * amplitude.x
		next.y = sign(next.y) * sqrt(amplitude_max * amplitude_max - next.x * next.x)
	elif amplitude.y < amplitude_max and abs(next.y) > amplitude.y:
		next.y = sign(next.y) * amplitude.y
		next.x = sign(next.x) * sqrt(amplitude_max * amplitude_max - next.y * next.y)

	loop = create_tween().set_parallel()
	for i in range(origins.size()):
		var next_value = -next if (targets[i] is Control and inverse_control_nodes) else next
		loop.tween_property(targets[i], "position", origins[i] + next_value * intensity, step)

	current = next
	loop.finished.connect(loop_func)
