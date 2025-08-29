extends Node2D

signal pass_info_to_arena(ennemies_infos, party_info)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var party: Node2D = $Party


var char_scene: PackedScene = load("uid://b3y2sr2uweroy")
var scene_arena: PackedScene = load("uid://ccgdngh77m0hc")
var scene_arena_ui: PackedScene = load("uid://dpnhc72tu6qee")
var shop_ui : PackedScene = load("uid://duf7bdfx04xnu")
var scene_quest_ui: PackedScene = load("uid://wn0rp33fbpef")

var wave_info: Array
var party_info: Array
var possibles_starter: Array = [LogicalCharacter.TYPES.Knight, LogicalCharacter.TYPES.Wizard, LogicalCharacter.TYPES.Farmer, LogicalCharacter.TYPES.Necromancer, LogicalCharacter.TYPES.Ranger]

#//////////function//////////
func _ready() -> void:
	spawn_party()
	


func spawn_party():
	var lPlayers_spawned: Array = party.get_children()
	#for players: AnimatedSprite2D in lPlayers_spawned:
	if lPlayers_spawned[0].sprite_frames != null:
		print("caca")
		 #players exist ... le faire spawn et l'ajouter pour le spawn à l'arena
	else:
		randomize()
		var lPlayer_type = possibles_starter.pick_random()
		party_info.append(lPlayer_type)
		match lPlayer_type:
			LogicalCharacter.TYPES.Knight:
				lPlayers_spawned[0].sprite_frames = load("uid://bya4yxuvdd8au")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Wizard:
				lPlayers_spawned[0].sprite_frames = load("uid://web178x58oer")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Farmer:
				lPlayers_spawned[0].sprite_frames = load("uid://d4bsbcou2jxx0")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Necromancer:
				lPlayers_spawned[0].sprite_frames = load("uid://devpvt8vd06qp")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Ranger:
				lPlayers_spawned[0].sprite_frames = load("uid://3x72wu7mgqcc")
				lPlayers_spawned[0].play("default")


func switch_scene():
	# We sapwn the arenaUI before the arena to avoid signals bug
	var lArena_ui: Control = scene_arena_ui.instantiate()
	UI.instance.add_child(lArena_ui)
	
	var lArena: Node2D = scene_arena.instantiate()
	get_parent().add_child(lArena)
	
	hide()
	camera_2d.enabled = false
	
	emit_signal("pass_info_to_arena", wave_info, party_info)


func _on_board_pressed() -> void:
	print("ui quest")
	var quest_ui: Control = scene_quest_ui.instantiate()
	UI.instance.add_child(quest_ui)
	level_select_ui.instance.connect("start_level", get_ennemies_info)
	
	
func _on_door_pressed() -> void:
	animation_player.active = true # This will trigger switch_scene


func _on_merchant_pressed() -> void:
	var shop  : Control = shop_ui.instantiate()
	UI.instance.add_child(shop)
	#merchant_ui.instance.connect("update_cookies", test)
	#marchant menu
	
func test(cookies):
	print(cookies)


func get_ennemies_info(pWave_info: Array):
	wave_info = pWave_info
