extends Node

#TODO This solution sucks ass, check something more like:
# https://www.reddit.com/r/godot/comments/1oda0ly/easy_font_scaling_code/

var current_scale: float = 1.0
var _base_sizes: Dictionary = { } # Control -> base font size (int)


func _ready():
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node):
	if node is Control:
		_apply_to_node(node, current_scale)


func set_global_font_scale(scale: float):
	current_scale = scale
	_apply_recursive(get_tree().root, scale)


func _apply_recursive(node: Node, scale: float):
	if node is Control:
		_apply_to_node(node, scale)
	for child in node.get_children():
		_apply_recursive(child, scale)


func _apply_to_node(node: Control, scale: float):
	if not _base_sizes.has(node):
		var current = node.get_theme_font_size("font_size")
		_base_sizes[node] = current if current > 0 else 16
		node.tree_exited.connect(func(): _base_sizes.erase(node), CONNECT_ONE_SHOT)

	var base: int = _base_sizes[node]
	node.add_theme_font_size_override("font_size", int(base * scale))
