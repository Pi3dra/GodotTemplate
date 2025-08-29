extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D

var scene_arena: PackedScene = load("uid://ccgdngh77m0hc")
var scene_arena_ui: PackedScene = load("uid://dpnhc72tu6qee")
var shop_ui : PackedScene = load("uid://duf7bdfx04xnu")

#//////////function//////////
func _ready() -> void:
	pass


func switch_scene():
	# We sapwn the arenaUI before the arena to avoid signals bug
	var lArena_ui: Control = scene_arena_ui.instantiate()
	UI.instance.add_child(lArena_ui)
	
	var lArena: Node2D = scene_arena.instantiate()
	get_parent().add_child(lArena)
	
	hide()
	camera_2d.enabled = false
	

func _on_board_pressed() -> void:
	print("ui quest")
	#ui quest

func _on_door_pressed() -> void:
	animation_player.active = true # This will trigger switch_scene


func _on_merchant_pressed() -> void:
	var shop  : Control = shop_ui.instantiate()
	UI.instance.add_child(shop)
	#merchant_ui.instance.connect("update_cookies", test)
	#marchant menu
	
func test(cookies):
	print(cookies)
