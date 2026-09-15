class_name EffectContext
extends RefCounted

# TODO Should adapt this so that effects can apply tween effects and behaviours 

var target: Node
var data: Dictionary = {}


func _init(p_target: Node) -> void:
	target = p_target
