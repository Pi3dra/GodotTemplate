extends Node2D

signal pass_info_to_arena(ennemies_infos, party_info)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var party: Node2D = $Party
@onready var cookie_holder: BoxContainer = $PanelContainer2/CookieHolder
@onready var partyfull: Label = $partyfull

var scene_arena: PackedScene = load("uid://ccgdngh77m0hc")
var scene_arena_ui: PackedScene = load("uid://dpnhc72tu6qee")

var level_data = { "WaveInfo": [], "PartyInfo": [], "Rewards": { }, "RiskedBiscuits": { } }
var party_info: Array[LogicalCharacter.TYPE] = []
var available_cookies: Dictionary[Cookie.TYPE, int] = { Cookie.TYPE.Normal: 30, Cookie.TYPE.Weighted: 1 }
var finished_level = false


func _ready() -> void:
	partyfull.hide()

	party_info.append(party.choose_random_char())
	party.spawn_party(party_info)
	party.connect("attempt_to_buy_char", attempt_to_buy_char)
	party.spawn_characters(party_info)

	move_child($ColorRect, get_children().size())
	print(available_cookies)
	launch_tutorial()
	update_cookie_bar()


func launch_tutorial():
	if Globals.current_tutorial != null:
		UI.manager.call_overlay(UI.NAME.Tutorial, self)

#region Signal handler and UI

# Flow
# board_pressed -> cookie_selection -> update_after_cookie -> switch scene
# Trainer -> switch scene

func _on_board_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	var ui_name = UI.NAME.LevelSelection
	UI.manager.call_overlay(ui_name, self)
	UI.manager.connect_signals(ui_name, { }, { "start_level": cookie_selection })


# After _on_board_pressed() we launch the cookie selection UI
func cookie_selection(data: Dictionary):
	var ui_name = UI.NAME.CookieSelection
	UI.manager.call_overlay(ui_name, self, available_cookies.duplicate())
	UI.manager.connect_signals(ui_name, { }, { "selected_cookie_deck": update_after_cookie_selection })
	level_data["WaveInfo"] = data["WaveInfo"]
	level_data["Rewards"] = data["Rewards"]
	level_data["PartyInfo"] = party_info


## TODO: level selection getting restarted if cookie select and exit
func update_after_cookie_selection(risked_biscuits: Dictionary[Cookie.TYPE, int]):
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

	UI.manager.remove_overlay(UI.NAME.LevelSelection)
	finished_level = false


func switch_scene():
	var level_information: Dictionary
	if Globals.training:
		level_information = {
			"WaveInfo": [[LogicalCharacter.TYPE.Unkillable_Slime], [LogicalCharacter.TYPE.Unkillable_Slime], [LogicalCharacter.TYPE.Unkillable_Slime]],
			"RiskedBiscuits": available_cookies.duplicate(),
			"PartyInfo": party_info,
			"Rewards": { "": 0, " ": 0 },
		}
	else:
		level_information = level_data

	var lArena: Node2D = scene_arena.instantiate()
	UI.manager.call_overlay(UI.NAME.Arena, lArena, level_information["RiskedBiscuits"])
	get_parent().add_child(lArena)
	hide()
	camera_2d.enabled = false
	emit_signal("pass_info_to_arena", level_information)


func _on_merchant_pressed() -> void:
	SoundManager.instance.play_sound("Click4", true, false)
	var ui_name = UI.NAME.Merchant
	UI.manager.call_overlay(ui_name, self, available_cookies)
	UI.manager.connect_signals(ui_name, { }, { "exited_merchant": update_after_merchant })


func _on_trainer_pressed() -> void:
	SoundManager.instance.play_sound("Click4", true, false)
	Globals.training = true
	Globals.current_tutorial = tutorial.TUTORIALS.Combat
	if !Globals.already_trained:
		launch_tutorial()
	animation_player.play("Transition") # This will trigger switch_scene

#endregion

#region dirt
func update_after_victory(characters, rewarded_cookies):
	party_info = characters

	for cookie in rewarded_cookies.keys():
		available_cookies[cookie] = available_cookies.get(cookie, 0) + rewarded_cookies[cookie]

	finished_level = true
	update_cookie_bar()
	party.spawn_characters(party_info)
	party.spawn_party(party_info)


func data_is_empty(data):
	var empty: bool = true
	for key in data.keys():
		empty = empty and data[key].is_empty()
	return empty


func update_cookie_bar():
	cookie_holder.available_cookies = available_cookies
	cookie_holder.update_cookie_bar()

#region Updates after buying stuff

func update_after_merchant(cookies):
	available_cookies = cookies
	update_cookie_bar()


func attempt_to_buy_char(character_instance):
	var character_type: LogicalCharacter.TYPE = character_instance.character
	var character_data: CharacterData = Globals.get_character_data(character_type)
	var character_price: int = character_data.price

	if character_price > available_cookies[Cookie.TYPE.Normal]:
		return

	if party.is_party_full():
		partyfull.show() # show the labe
		var tween = create_tween()
		tween.tween_property(partyfull, "modulate:a", partyfull.modulate.a, 1.0) #Do nothing
		tween.tween_callback(Callable(partyfull, "hide")) # hide after delay
		return

	if character_price <= available_cookies[Cookie.TYPE.Normal]:
		available_cookies[Cookie.TYPE.Normal] -= character_price
		update_cookie_bar()
		party_info.append(character_type)
		party.clear_npc(character_type)
		party.spawn_party(party_info)

#endregion

#region button signal land

func set_hover_effect(node, hovered: bool, cursor_texture: Texture = Cursor.basic):
	node.scale = Vector2(1.5, 1.5) if hovered else Vector2(1, 1)
	Cursor.instance.texture = cursor_texture


@onready var board = $Board


func _on_board_mouse_entered() -> void:
	set_hover_effect(board, true, Cursor.eye)


func _on_board_mouse_exited() -> void:
	set_hover_effect(board, false)


@onready var merchant = $Merchant/AnimatedSprite2D


func _on_merchant_mouse_entered() -> void:
	set_hover_effect(merchant, true, Cursor.chat)


func _on_merchant_mouse_exited() -> void:
	set_hover_effect(merchant, false)


@onready var trainer = $Trainer/AnimatedSprite2D


func _on_trainer_mouse_entered() -> void:
	set_hover_effect(trainer, true, Cursor.chat)


func _on_trainer_mouse_exited() -> void:
	set_hover_effect(trainer, false)

#endregion
