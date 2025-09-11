extends Node2D

signal pass_info_to_arena(ennemies_infos, party_info)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var party: Node2D = $Party
@onready var trainer = $Trainer/AnimatedSprite2D

var char_scene: PackedScene = load("uid://b3y2sr2uweroy")
var scene_arena: PackedScene = load("uid://ccgdngh77m0hc")
var scene_arena_ui: PackedScene = load("uid://dpnhc72tu6qee")
var pelo_tscn: PackedScene = load("res://Scenes/GameScene/tavern_char.tscn")

var level_data = {"WaveInfo" : [], "PartyInfo" : [], "Rewards" : {} , "RiskedBiscuits" : {}}

var party_info : Array[LogicalCharacter.TYPE] = []


var possibles_starter: Array = [LogicalCharacter.TYPE.Knight, LogicalCharacter.TYPE.Wizard, LogicalCharacter.TYPE.Farmer, LogicalCharacter.TYPE.Necromancer, LogicalCharacter.TYPE.Ranger]
var available_cookies : Dictionary[Cookie.TYPE, int]= {Cookie.TYPE.Normal : 10, Cookie.TYPE.Berserk : 2, Cookie.TYPE.Head : 2, Cookie.TYPE.Weighted: 1}
@onready var partyfull: Label = $partyfull

var finished_level = false
var buyable_char_nodes : Dictionary


#//////////function//////////
func _ready() -> void:
	partyfull.hide()
	choose_starter_character()
	spawn_characters()
	move_child($ColorRect, get_children().size())
	launch_tutorial()
	update_cookie_bar()
	

func launch_tutorial():
	if Globals.current_tutorial != null:
		UI.manager.call_overlay(UI.NAME.Tutorial,self)

#region Random Character Spawner

func choose_starter_character():
	var lPlayers_spawned: Array = party.get_children()
	#for players: AnimatedSprite2D in lPlayers_spawned:
	randomize()
	var lPlayer_type = possibles_starter.pick_random()
	possibles_starter.erase(lPlayer_type)
	party_info.append(lPlayer_type)
	#TODO This could be done easily with tavern_tscn and used 
	var char_data : CharacterData = Globals.get_character_data(lPlayer_type)
	lPlayers_spawned[0].sprite_frames =  char_data.animations
	lPlayers_spawned[0].play("default")


### For each 4 characters we spawn, we first decide if we spawn it, and if we do we pick a character randomly
### We also vary their prices a bit
func choose_chars() ->  Array[LogicalCharacter.TYPE]:
	### TODO: this is supposed to not make
	var chars_not_picked_yet = possibles_starter.duplicate()
	for character in party_info:
		chars_not_picked_yet.erase(character)
		
	var characters_to_spawn : Array[LogicalCharacter.TYPE] = []
	
	for i in range(3):
		var spawn_enemy = randf() <= 0.75
		if spawn_enemy:
			#TODO this seems to be generating a bug, somehow chars_not_picked_yet can be empty
			var character = chars_not_picked_yet.pick_random()
			chars_not_picked_yet.erase(character)
			characters_to_spawn.append(character)
	return characters_to_spawn

func spawn_character(character :LogicalCharacter.TYPE, char_position):
		var character_instance = pelo_tscn.instantiate()
		character_instance.call_deferred("init_char",character)
		character_instance.connect("buy_character", buy_character)
		# Tavern NPCs never get repeated so using a dictioinary makes sense
		buyable_char_nodes.set(character, character_instance)
		character_instance.global_position = char_position
		add_child(character_instance)

func spawn_characters() -> void:
	var characters_to_spawn = choose_chars()
	var markers = $Spawners.get_children()
	var positions = markers.map(func(marker): return marker.position)
	for i in range(characters_to_spawn.size()):
		spawn_character(characters_to_spawn[i], positions[i])



func buy_character(character, character_price):
	SoundManager.instance.play_sound("Click4", true, false)
	if character_price > available_cookies[Cookie.TYPE.Normal]:
		return
	var party_slots = $Party.get_children()
	var spawned = false
	for slot in party_slots:
		if slot.sprite_frames == null and available_cookies[Cookie.TYPE.Normal] >= character_price and !spawned : # Façon assez degueu de savoir si un slot est libre
			available_cookies[Cookie.TYPE.Normal] -= character_price
			slot.sprite_frames =  Globals.get_character_data(character).animations
			slot.play("default")
			party_info.append(character)
			buyable_char_nodes.get(character).queue_free()
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

# Flow  
# board_pressed -> cookie_selection -> update_after_cookie -> switch scene
# Trainer -> switch scene

func _on_board_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	var ui_name = UI.NAME.LevelSelection
	UI.manager.call_overlay(ui_name, self)
	UI.manager.connect_signals(ui_name, {} , {"start_level" : cookie_selection})
	
	
# After _on_board_pressed() we launch the cookie selection UI
func cookie_selection(data : Dictionary):
	var ui_name = UI.NAME.CookieSelection
	UI.manager.call_overlay(ui_name,self, available_cookies.duplicate())
	UI.manager.connect_signals(ui_name, {}, {"selected_cookie_deck": update_after_cookie_selection})
	level_data["WaveInfo"] = data["WaveInfo"]
	level_data["Rewards"] = data["Rewards"]
	level_data["PartyInfo"] = party_info

## TODO: level selection getting restarted if cookie select and exit
func update_after_cookie_selection(risked_biscuits : Dictionary[Cookie.TYPE, int]):
	level_data["RiskedBiscuits"] = risked_biscuits
	
	#Remove from available_cookies:
	for cookie in risked_biscuits.keys():
		available_cookies.set(cookie, available_cookies[cookie] - risked_biscuits[cookie])
	
	# Launch combat
	if !level_data["WaveInfo"].is_empty() and !risked_biscuits.is_empty():
		SoundManager.instance.play_sound("Tavern", false)
		SoundManager.instance.play_sound("Transition", true, true)
		animation_player.play("Transition") # This will trigger switch_scene
	else: 
		SoundManager.instance.play_sound("Stopit", true, false)
	finished_level = false

	
func switch_scene():
	var level_information : Dictionary
	if Globals.training:
		level_information = {
		"WaveInfo" : [[LogicalCharacter.TYPE.Unkillable_Slime],[LogicalCharacter.TYPE.Unkillable_Slime],[LogicalCharacter.TYPE.Unkillable_Slime]],
		"RiskedBiscuits" : available_cookies.duplicate(),
		"PartyInfo": party_info,
		"Rewards" : {"":0," ":0}
		}
	else:
		level_information = level_data
		
	var lArena: Node2D = scene_arena.instantiate()
	UI.manager.call_overlay(UI.NAME.Arena, lArena ,level_information["RiskedBiscuits"])
	get_parent().add_child(lArena)
	hide()
	camera_2d.enabled = false
	emit_signal("pass_info_to_arena", level_information)

func _on_merchant_pressed() -> void:
	SoundManager.instance.play_sound("Click4", true, false)
	var ui_name = UI.NAME.Merchant
	UI.manager.call_overlay(ui_name,self,available_cookies)
	UI.manager.connect_signals(ui_name, {} , {"exited_merchant" : update_after_merchant})


func update_after_merchant(cookies):
	available_cookies = cookies
	update_cookie_bar()

func _on_trainer_pressed() -> void:
	SoundManager.instance.play_sound("Click4", true, false)
	Globals.training = true
	Globals.current_tutorial = tutorial.TUTORIALS.Combat
	if !Globals.already_trained:
		launch_tutorial()
	animation_player.play("Transition") # This will trigger switch_scene
	

#endregion

#region button signal land, careful to not get lost, this is utter madness

# TODO: this could be abstracted by a simple signal
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

func _on_trainer_mouse_entered() -> void:
	trainer.scale = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.chat
func _on_trainer_mouse_exited() -> void:
	trainer.scale = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic
#endregion

#region dirt
func update_after_victory(characters,rewarded_cookies):
	party_info = characters
	for cookie in rewarded_cookies.keys():
		if rewarded_cookies[cookie] > 0:
			if available_cookies.has(cookie):
				available_cookies.set(cookie, available_cookies[cookie] + rewarded_cookies[cookie])
			else:
				available_cookies.set(cookie, rewarded_cookies[cookie])
	#wave_info.clear()
	#level_reward1 = 0
	#level_reward2 = 0
	
	for character in buyable_char_nodes.keys():
		buyable_char_nodes[character].queue_free(
		)
	buyable_char_nodes.clear()
	finished_level = true
	update_cookie_bar()
	spawn_characters()
	update_party_sprites()
	
func update_party_sprites():
	var party_slots = party.get_children()
	# TODO: this should rather be done in spawn_characters
	for sprites in party_slots:
		sprites.sprite_frames = null
	for character in party_info:
		var chosen_slot = party_slots.pick_random()
		chosen_slot.sprite_frames = Globals.get_character_data(character).animations
		chosen_slot.play("default")
		party_slots.erase(chosen_slot)
	finished_level = true
			

# TODO Rethink this
var cookie_nodes = {}
@onready var cookie_bar = $PanelContainer/CookierBar
func update_cookie_bar():
	for cookietype in available_cookies.keys():
		if !cookie_nodes.has(cookietype) and available_cookies[cookietype] > 0:
			var label = Label.new()
			label.text = "  " +str(available_cookies[cookietype]) + "X"
			label.theme_type_variation = "TextBox"
			var texture = TextureRect.new()
			texture.texture = Globals.get_cookie_data(cookietype).head_texture
			label.theme_type_variation = "SmallTextBox"
			texture.custom_minimum_size = Vector2(16, 16)  # 11x11
			texture.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			texture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			texture.scale = Vector2(0.5,0.5)
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

func data_is_empty(data):
	var empty : bool = true
	for key in data.keys():
		empty = empty and data[key].is_empty()
	return empty

#endregion
