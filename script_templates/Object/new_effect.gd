# meta-name: Effect
# meta-description: Basic skeleton for defining your own Effects
# meta-space-indent: 4
class_name _CLASS_
extends Effect

var strength: float
var duration: float


func _init(
		p_duration: float,
		p_strength: float,
) -> void:
	duration = p_duration
	strength = p_strength


func _start() -> Tween:
	var node := target as CanvasItem
	if node == null:
		return null # finishes instantly

	var tween := target.create_tween()

	return tween


func _cleanup(_cancelled: bool) -> void:
	pass
