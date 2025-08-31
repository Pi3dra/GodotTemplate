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
var tutorial_tscn : PackedScene = load("res://Scenes/UI/tutorial.tscn")

var wave_info: Array = []
var party_info: Array
var level_reward1 : int
var level_reward2 :int

var risked_biscuits = {}

var possibles_starter: Array = [LogicalCharacter.TYPES.Knight, LogicalCharacter.TYPES.Wizard, LogicalCharacter.TYPES.Farmer, LogicalCharacter.TYPES.Necromancer, LogicalCharacter.TYPES.Ranger]
var available_cookies : Dictionary[Cookie.TYPE, int]= {Cookie.TYPE.Normal : 5, Cookie.TYPE.Berserk : 2, Cookie.TYPE.Head : 2, Cookie.TYPE.Weighted: 1}
@onready var partyfull: Label = $partyfull

var finished_level = false
var buyable_char_nodes : Dictionary


#//////////function//////////
func _ready() -> void:
	UI.instance.connect("beginning_finished", can_start)
	
	partyfull.hide()
	spawn_characters()
	spawn_party()
	move_child($ColorRect, get_children().size())
	launch_tutorial()
	update_cookie_bar()
	

func can_start():
	SoundManager.instance.play_sound("Tavern", true, false)

func launch_tutorial():
	if Globals.current_tutorial != null:
		var tuto = tutorial_tscn.instantiate()
		UI.instance.add_child(tuto)

func spawn_party():
	var lPlayers_spawned: Array = party.get_children()
	#for players: AnimatedSprite2D in lPlayers_spawned:
	if lPlayers_spawned[0].sprite_frames != null:
		print("ya deja un joueur askip")
		 #players exist ... le faire spawn et l'ajouter pour le spawn à l'arena
	else:
		randomize()
		var lPlayer_type = possibles_starter.pick_random()
		possibles_starter.erase(lPlayer_type)
		party_info.append(lPlayer_type)
		match lPlayer_type:
			LogicalCharacter.TYPES.Knight:
				lPlayers_spawned[0].sprite_frames = load("uid://b2ygb7ty6nyn7")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Wizard:
				lPlayers_spawned[0].sprite_frames = load("uid://ceggmtt6ni5yw")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Farmer:
				lPlayers_spawned[0].sprite_frames = load("uid://bsek4eo8s6x7f")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Necromancer:
				lPlayers_spawned[0].sprite_frames = load("uid://b28w73d4lebir")
				lPlayers_spawned[0].play("default")
			LogicalCharacter.TYPES.Ranger:
				lPlayers_spawned[0].sprite_frames = load("uid://cd1mc8i0dxna8")
				lPlayers_spawned[0].play("default")


#region Random Character Spawner

### For each 4 characters we spawn, we first decide if we spawn it, and if we do we pick a character randomly
### We also vary their prices a bit
func choose_chars() ->  Array[LogicalCharacter.TYPES]:
	var chars_not_picked_yet = possibles_starter.duplicate()
	
	for char in party_info:
		chars_not_picked_yet.erase(char)
		
	var characters_to_spawn : Array[LogicalCharacter.TYPES] = []
	
	for i in range(3):
		var spawn_enemy = randf() <= 0.75
		if spawn_enemy:
			var char = chars_not_picked_yet.pick_random()
			chars_not_picked_yet.erase(char)
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
	SoundManager.instance.play_sound("Click4", true, false)
	# TODO Handle case when party is full
	var party_slots = $Party.get_children()
	var spawned = false
	for slot in party_slots:
		if slot.sprite_frames == null and available_cookies[Cookie.TYPE.Normal] >= character_price and !spawned : # Façon assez degueu de savoir si un slot est libre
			available_cookies[Cookie.TYPE.Normal] -= character_price
			slot.sprite_frames =  LogicalCharacter.char_to_sprite(character)
			slot.play("default")
			party_info.append(character)
			buyable_char_nodes[character].queue_free()
			print("ERASED has to be typee: ", character)
			buyable_char_nodes.erase(character)
			spawned = true #Add only one
	update_cookie_bar()
	if !spawned:
		partyfull.show()  # show the labe	
		var tween = create_tween()
		tween.tween_property(partyfull, "modulate:a", partyfull.modulate.a,  1.0) #Do nothing
		tween.tween_callback(Callable(partyfull, "hide"))  # hide after delay
	
	
#endregion


#region Signal handler and UI
func switch_scene():
	# We sapwn the arenaUI before the arena to avoid signals bug
	var lArena_ui: Control = scene_arena_ui.instantiate()
	UI.instance.add_child(lArena_ui)
	UI.instance.move_child(lArena_ui,0)
	var lArena: Node2D = scene_arena.instantiate()
	get_parent().add_child(lArena)
	lArena_ui.init(risked_biscuits)
	hide()
	camera_2d.enabled = false
	
	emit_signal("pass_info_to_arena", wave_info, party_info, level_reward1, level_reward2)


func _on_board_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	if level_select_ui.instance != null and !finished_level :
		level_select_ui.instance.show()
		return
	if level_select_ui.instance != null and finished_level:
		level_select_ui.instance.queue_free()
	var quest_ui: Control = scene_quest_ui.instantiate()
	UI.instance.add_child(quest_ui)
	level_select_ui.instance.connect("start_level", cookie_selection)
	
# After _on_board_pressed() we launch the cookie selection UI

func cookie_selection(pWave_info: Array, reward1, reward2):
	var cookie_selection_ui = cookie_ui.instantiate()
	UI.instance.add_child(cookie_selection_ui)
	cookie_select_ui.instance.connect("selected_cookie_deck", update_after_cookie_selection)
	
	#restore cookies in case the player decides to choose something else
	if !risked_biscuits.is_empty():
		for cookie in risked_biscuits.keys():
			if available_cookies.has(cookie):
				available_cookies[cookie] += risked_biscuits[cookie]
			else:
				available_cookies.set(cookie, risked_biscuits[cookie])
	
	
	#TODO connect data
	cookie_selection_ui.call_deferred("set_available_cookies", available_cookies.duplicate())
	
	print("rew ", reward1, " ", reward2)
	level_reward1 = reward1
	level_reward2 = reward2
	wave_info = pWave_info

func update_after_cookie_selection(cookies : Dictionary[Cookie.TYPE, int]):
	risked_biscuits = cookies
	for biscuit in risked_biscuits.keys():
		available_cookies[biscuit] -= risked_biscuits[biscuit]
		print("todo")
		
func _on_door_pressed() -> void:
	if !wave_info.is_empty() and !risked_biscuits.is_empty():
		SoundManager.instance.play_sound("Tavern", false)
		SoundManager.instance.play_sound("Transition", true, true)
		animation_player.play("Transition") # This will trigger switch_scene
	else: SoundManager.instance.play_sound("Stopit", true, false)

func _on_merchant_pressed() -> void:
	SoundManager.instance.play_sound("Click4", true, false)
	var shop  : Control = shop_ui.instantiate()
	shop.call_deferred("set_available_cookies", available_cookies)
	UI.instance.add_child(shop)
	merchant_ui.instance.connect("update_cookies", update_after_merchant)
	#marchant menu
	
func update_after_merchant(cookies):
	cookie_select_ui.instance
	available_cookies = cookies
	update_cookie_bar()
#endregion

#region button signal land, careful to not get lost, this is utter madness

@onready var board = $Board
func _on_board_mouse_entered() -> void:
	board.pivot_offset = board.size/2
	board.scale = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.eye
	
func _on_board_mouse_exited() -> void:
	board.pivot_offset = board.size/2
	board.scale = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic

@onready var merchant = $Merchant/AnimatedSprite2D
func _on_merchant_mouse_entered() -> void:
	merchant.scale  = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.chat
func _on_merchant_mouse_exited() -> void:
	merchant.scale  = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic

@onready var door: TextureButton = $Door
func _on_door_mouse_entered() -> void:
	door.pivot_offset = door.size/2
	door.scale  = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.step
	
func _on_door_mouse_exited() -> void:
	door.pivot_offset = door.size/2
	door.scale  = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic

@onready var trainer = $Trainer/AnimatedSprite2D
func _on_trainer_pressed() -> void:
	SoundManager.instance.play_sound("Click4", true, false)
	Globals.training = true
	Globals.current_tutorial = tutorial.TUTORIALS.Combat
	if !Globals.already_trained:
		launch_tutorial()
		
	risked_biscuits = available_cookies
	wave_info = [[LogicalCharacter.TYPES.Unkillable_Slime],[LogicalCharacter.TYPES.Unkillable_Slime],[LogicalCharacter.TYPES.Unkillable_Slime]]
	print(party_info, wave_info)
	if wave_info != null and risked_biscuits != null:
		animation_player.play("Transition") # This will trigger switch_scene
	
		

func _on_trainer_mouse_entered() -> void:
	trainer.scale = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.chat
func _on_trainer_mouse_exited() -> void:
	trainer.scale = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic
#endregion

func update_after_victory(characters,rewarded_cookies):
	party_info = characters
	for cookie in rewarded_cookies.keys():
		if rewarded_cookies[cookie] > 0:
			if available_cookies.has(cookie):
				available_cookies.set(cookie, available_cookies[cookie] + rewarded_cookies[cookie])
			else:
				available_cookies.set(cookie, rewarded_cookies[cookie])
	wave_info.clear()
	level_reward1 = 0
	level_reward2 = 0
	
	for char in buyable_char_nodes.keys():
		buyable_char_nodes[char].queue_free(
		)
	buyable_char_nodes.clear()
	
	update_cookie_bar()
	spawn_characters()
	update_party_sprites()
	
func update_party_sprites():
	var party_slots = party.get_children()
	for sprites in party_slots:
		sprites.sprite_frames = null
		
	for char in party_info:
		var chosen_slot = party_slots.pick_random()
		chosen_slot.sprite_frames = LogicalCharacter.char_to_sprite(char)
		chosen_slot.play("default")
		party_slots.erase(chosen_slot)
	finished_level = true
			

var cookie_nodes = {}
@onready var cookie_bar = $PanelContainer/CookierBar
func update_cookie_bar():
	for cookietype in available_cookies.keys():
		if !cookie_nodes.has(cookietype) and available_cookies[cookietype] > 0:
			var label = Label.new()
			label.text = "  " +str(available_cookies[cookietype]) + "X"
			label.theme_type_variation = "TextBox"
			var texture = TextureRect.new()
			texture.texture = Cookie.type_sprite(cookietype)
			
			label.theme_type_variation = "SmallTextBox"
			#texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			#texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE
			texture.custom_minimum_size = Vector2(16, 16)  # 11x11
			#texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			texture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			texture.scale = Vector2(0.5,0.5)
			#texture.expand = false
			cookie_nodes[cookietype] = [label,texture]
			cookie_bar.add_child(label)
			cookie_bar.add_child(texture)
			
		elif available_cookies[cookietype] == 0 and cookie_nodes.has(cookietype):
			var nodes = cookie_nodes[cookietype]
			var text = nodes[0]
			text.hide()
			var icon = nodes[1]
			icon.hide()
		elif cookie_nodes.has(cookietype) and available_cookies[cookietype] > 0:
			var nodes = cookie_nodes[cookietype]
			var text = nodes[0]
			text.show()
			var icon = nodes[1]
			icon.show()
			text.text = "  " +str(available_cookies[cookietype]) + "X"
