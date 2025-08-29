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
var cookie_ui: PackedScene = load("res://Scenes/UI/cookie_select_ui.tscn")
var pelo_tscn: PackedScene = load("res://Scenes/GameScene/tavern_char.tscn")

var wave_info: Array
var party_info: Array
var possibles_starter: Array = [LogicalCharacter.TYPES.Knight, LogicalCharacter.TYPES.Wizard, LogicalCharacter.TYPES.Farmer, LogicalCharacter.TYPES.Necromancer, LogicalCharacter.TYPES.Ranger]
var available_cookies : Dictionary[Cookie.TYPE, int]= {Cookie.TYPE.Normal : 6}
var risked_biscuits = {Cookie.TYPE.Normal : 20}

var buyable_char_nodes : Dictionary

#//////////function//////////
func _ready() -> void:
	spawn_characters()
	spawn_party()
	move_child($ColorRect, get_children().size())

func spawn_party():
	var lPlayers_spawned: Array = party.get_children()
	#for players: AnimatedSprite2D in lPlayers_spawned:
	if lPlayers_spawned[0].sprite_frames != null:
		print("caca")
		 #players exist ... le faire spawn et l'ajouter pour le spawn à l'arena
	else:
		randomize()
		var lPlayer_type = possibles_starter.pick_random()
		possibles_starter.erase(lPlayer_type)
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


#region Random Character Spawner

### For each 4 characters we spawn, we first decide if we spawn it, and if we do we pick a character randomly
### We also vary their prices a bit
func choose_chars() ->  Array[LogicalCharacter.TYPES]:
	# TODO add special chars to possible starter
	var characters_to_spawn : Array[LogicalCharacter.TYPES] = []
	for i in range(3):
		var spawn_enemy = randf() <= 0.75
		if spawn_enemy:
			var char = possibles_starter.pick_random()
			possibles_starter.erase(char)
			characters_to_spawn.append(char)
	return characters_to_spawn



func spawn_characters() -> void:
	var characters_to_spawn = choose_chars()
	var markers = $Spawners.get_children()
	var positions = markers.map(func(marker): return marker.position)
	for i in range(characters_to_spawn.size()):
		var char = pelo_tscn.instantiate()
		char.call_deferred("init_char",characters_to_spawn[i])
		add_child(char)
		char.connect("buy_character", buy_character)
		buyable_char_nodes.set(characters_to_spawn[i], char)
		char.global_position = positions[i]

func buy_character(character, character_price):
	if available_cookies[Cookie.TYPE.Normal] >= character_price:
		available_cookies[Cookie.TYPE.Normal] -= character_price
	else:
		return
		
	var party_slots = $Party.get_children()
	for slot in party_slots:
		if slot.sprite_frames == null: # Façon assez degueu de savoir si un slot est libre
			slot.sprite_frames =  load("uid://web178x58oer")
			slot.play("default")
			party_info.append(character)
			buyable_char_nodes[character].queue_free()
			return #Add only one
	
#endregion


#region Signal handler and UI
func switch_scene():
	# We sapwn the arenaUI before the arena to avoid signals bug
	var lArena_ui: Control = scene_arena_ui.instantiate()
	UI.instance.add_child(lArena_ui)
	
	var lArena: Node2D = scene_arena.instantiate()
	get_parent().add_child(lArena)
	lArena_ui.init(risked_biscuits)
	hide()
	camera_2d.enabled = false
	
	emit_signal("pass_info_to_arena", wave_info, party_info)


func _on_board_pressed() -> void:
	if level_select_ui.instance != null:
		level_select_ui.instance.show()
		return
	print("ui quest")
	var quest_ui: Control = scene_quest_ui.instantiate()
	UI.instance.add_child(quest_ui)
	level_select_ui.instance.connect("start_level", cookie_selection)
	
# After _on_board_pressed() we launch the cookie selection UI

func cookie_selection(pWave_info: Array):
	var cookie_selection_ui = cookie_ui.instantiate()
	UI.instance.add_child(cookie_selection_ui)
	cookie_select_ui.instance.connect("selected_cookie_deck", update_after_cookie_selection)
	#TODO connect data
	cookie_selection_ui.call_deferred("set_available_cookies", available_cookies.duplicate())
	wave_info = pWave_info

func update_after_cookie_selection(cookies : Dictionary[Cookie.TYPE, int]):
	risked_biscuits = cookies
	
func _on_door_pressed() -> void:
	if wave_info != null and risked_biscuits != null:
		animation_player.active = true # This will trigger switch_scene

func _on_merchant_pressed() -> void:
	var shop  : Control = shop_ui.instantiate()
	shop.call_deferred("set_available_cookies", available_cookies)
	UI.instance.add_child(shop)
	merchant_ui.instance.connect("update_cookies", update_after_merchant)
	#marchant menu
	
func update_after_merchant(cookies):
	cookie_select_ui.instance
	available_cookies = cookies
#endregion

#region button signal land, careful to not get lost, this is utter madness

@onready var board = $Board
func _on_board_mouse_entered() -> void:
	#board.set_pivot_offset = board.size/2
	board.pivot_offset = board.size/2
	board.scale = Vector2(1.5,1.5)
	
	#board.position.x = board.position.x + board.size.x/2
	#board.position.y = board.position.y + board.size.y/2
func _on_board_mouse_exited() -> void:
	board.pivot_offset = board.size/2
	board.scale = Vector2(1,1)
	#board.position.x = board.position.x - board.size.x/2
	#board.position.y = board.position.y - board.size.y/2

@onready var merchant = $Merchant/AnimatedSprite2D
func _on_merchant_mouse_entered() -> void:
	merchant.scale  = Vector2(1.5,1.5)
func _on_merchant_mouse_exited() -> void:
	merchant.scale  = Vector2(1,1)

@onready var door: TextureButton = $Door
func _on_door_mouse_entered() -> void:
	door.pivot_offset = door.size/2
	door.scale  = Vector2(1.5,1.5)
func _on_door_mouse_exited() -> void:
	door.pivot_offset = door.size/2
	door.scale  = Vector2(1,1)
#endregion
