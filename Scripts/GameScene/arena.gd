extends Node2D

signal combat_over(is_combat_over: bool)

@onready var enemies_spawners: Node2D = $EnemiesSpawners
@onready var enemies_spawners_2: Node2D = $EnemiesSpawners2
@onready var enemies_spawner_3: Node2D = $EnemiesSpawner3
@onready var ally_spawners: Node2D = $AllySpawners
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shaker: SimpleShaker = $Shaker
@onready var color_rect: ColorRect = $ColorRect
@onready var color_rect_2: ColorRect = $ColorRect2
@onready var camera_2d: Camera2D = $Camera2D
@onready var retry: RichTextLabel = $ButRetry/RETRY
@onready var game_over: RichTextLabel = $"GAME OVER"
@onready var but_retry: Button = $ButRetry
@onready var but_win: Button = $ControlWin/ButWin
@onready var win: RichTextLabel = $ControlWin/WIN
@onready var panel_container: PanelContainer = $ControlWin/PanelContainer
@onready var control_win: Control = $ControlWin

var char_scene: PackedScene = load("uid://b3y2sr2uweroy")
var main_scene: PackedScene = load("uid://dsrw2guvcxik7")

var chosen_enemies: Array[LogicalCharacter.TYPES]
var chosen_enemies2: Array[LogicalCharacter.TYPES]
var chosen_enemies3: Array[LogicalCharacter.TYPES]

# Engaged enemies
var player_party: Array[LogicalCharacter.TYPES]

var spawned_enemies: Array[Node2D]
var spawned_enemies2: Array[Node2D]
var spawned_enemies3: Array[Node2D]

var spawned_allies: Array[Node2D]

var enemies_spawn_pos: Array[Vector2]
var enemies_spawn_pos2: Array[Vector2]
var enemies_spawn_pos3: Array[Vector2]

var allies_spawn_pos: Array[Vector2]

var max_vague1: int
var max_vague2: int
var max_vague3: int

var you_stop: bool = false # For the process
var you_stop2: bool = false # For the process
var you_stop3: bool = false # For the process

var level_reward1: int
var level_reward2:int
var selected_special
#//////////function//////////
func _init():
	area_ui.instance.connect("combat_cookies", update_active_cookies)
	
func _ready() -> void:
	get_parent().get_child(0).connect("pass_info_to_arena", get_tavern_info)
	animation_player.play("Opening")
	
	
	for pos: Marker2D in enemies_spawners.get_children():
		enemies_spawn_pos.append(pos.position)
	for pos2: Marker2D in enemies_spawners_2.get_children():
		enemies_spawn_pos2.append(pos2.position)
	for pos3: Marker2D in enemies_spawner_3.get_children():
		enemies_spawn_pos3.append(pos3.position)
	
	for pos: Marker2D in ally_spawners.get_children():
		allies_spawn_pos.append(pos.position)
	
	


func _process(delta: float) -> void:
	if spawned_enemies.is_empty() and you_stop == false:
		animation_player.play("Ending")
		you_stop = true
		for allies in spawned_allies:
			allies.no_attacking()
	elif spawned_allies.is_empty() and you_stop == false:
		animation_player.play("Lose")
		you_stop = true
		for enemies in spawned_enemies:
			enemies.no_attacking()
			
	if spawned_enemies2.is_empty() and you_stop2 == false:
		animation_player.play("Ending2")
		you_stop2 = true
		for allies in spawned_allies:
			allies.no_attacking()
	elif spawned_allies.is_empty() and you_stop2 == false:
		animation_player.play("Lose")
		you_stop2 = true
		for enemies in spawned_enemies2:
			enemies.no_attacking()
		
	if spawned_enemies3.is_empty() and you_stop3 == false:
		animation_player.play("Win")
		you_stop3 = true
		for allies in spawned_allies:
			allies.no_attacking()
	elif spawned_allies.is_empty() and you_stop3 == false:
		animation_player.play("Lose")
		you_stop3 = true
		for enemies in spawned_enemies3:
			enemies.no_attacking()
	

func _on_visibility_changed() -> void:
	if visible == true: # This means that we leave the Tavern
		pass
	

func get_tavern_info(pWave_info, pParty_info, reward1, reward2):
	#region Wave_info
	var lWaves_numb: int
	var lEnnemies_par_wave = []
	var lChar_type: LogicalCharacter.TYPES
	# Parce que ça marche pas avec le foooooooooor
	var lWave_1: Array
	var lWave_2: Array
	var lWave_3: Array
	lWave_1 = pWave_info[0]
	lWave_2 = pWave_info[1]
	lWave_3 = pWave_info[2]
	
	lWaves_numb = pWave_info.size() # Nb of waves
	
	for wave in pWave_info:
		lEnnemies_par_wave.append(wave.size()) # This stock the nb of ennemies per wave
		
	max_vague1 = lEnnemies_par_wave[0]
	max_vague2 = lEnnemies_par_wave[1]
	max_vague3 = lEnnemies_par_wave[2]
	add_to_array(chosen_enemies, lEnnemies_par_wave[0], lWave_1)
	add_to_array(chosen_enemies2, lEnnemies_par_wave[1],lWave_2)
	add_to_array(chosen_enemies3, lEnnemies_par_wave[2],lWave_3)
	spawn_characters(chosen_enemies, enemies_spawn_pos, spawned_enemies)
	spawn_characters(chosen_enemies2, enemies_spawn_pos2, spawned_enemies2)
	spawn_characters(chosen_enemies3, enemies_spawn_pos3, spawned_enemies3)
	
	
	#endregion
	
	level_reward1 = reward1
	level_reward2 = reward2
	print("Arena, " ,reward1, reward2)
	#For player party
	add_to_array(player_party, pParty_info.size(), pParty_info)
	spawn_characters(player_party, allies_spawn_pos, spawned_allies)


func spawn_characters(pStr_array: Array[LogicalCharacter.TYPES], pVec_array: Array[Vector2], pNode_array: Array[Node2D]):
	for characters in pStr_array:
		create_character(characters)
	
	for i in range(pVec_array.size()):
		if i < pNode_array.size():
			pNode_array[i].position = pVec_array[i] # Adjust the pos of enemies to avaible spawn pos
	
	for allies in spawned_allies:
			allies.no_attacking()
	for enemies in spawned_enemies:
			enemies.no_attacking()
	for enemies in spawned_enemies2:
			enemies.no_attacking()
	for enemies in spawned_enemies3:
			enemies.no_attacking()
	move_child(color_rect, get_children().size())

func add_to_array(pArray: Array, pNumb: int, pChar_name: Array):
	#pArray.clear()
	for i in range(pNumb):
		pArray.append(pChar_name[i])


func create_character(pChar_name: LogicalCharacter.TYPES):
	# Creation character Class (pas egal a character.tscn)
	var lDict: Dictionary = GameScene.pokedex.get(pChar_name) # lDict = the character(pChar_name) dictionary of stat
	var lChar: LogicalCharacter = LogicalCharacter.new(lDict["Health"], lDict["Damage"], lDict["Speed"], lDict["Crit"], lDict["Sprite"], lDict["Side"], lDict["Shooter"])
	# Instantiation of character tscn
	var lCharScene : Node2D = char_scene.instantiate()
	lCharScene.character = lChar # Attribution of the logical character to the physical tscn of character
	add_child(lCharScene)
	
	lCharScene.connect("attack", combat_handler) # Get the signal from character
	
	match lDict["Side"]:
		"Good":
			spawned_allies.append(lCharScene)
		"Bad":
			if spawned_enemies.size() == max_vague1 and spawned_enemies2.size() == max_vague2:
				spawned_enemies3.append(lCharScene)
			elif spawned_enemies.size() == max_vague1:
				spawned_enemies2.append(lCharScene)
			else: spawned_enemies.append(lCharScene)

func combat_handler(Attack_info : Array, pSide, pShooter):
	var lList_to_pick : Array[Node2D] = []
	
	var lDamage = Attack_info[0]
	var lCrit = Attack_info[1]
	
	match pSide:
		"Good":
			lList_to_pick = spawned_enemies
			if spawned_enemies.is_empty() == true: lList_to_pick = spawned_enemies2
			if spawned_enemies2.is_empty() == true: lList_to_pick = spawned_enemies3
		"Bad":
			lList_to_pick = spawned_allies
			
	# TODO rajouter cas ou la liste est des allies ou des ennemis
	#if spawned_enemies == []:
		#return
	#elif spawned_allies == []:
		#return
	
	var lEnemy_to_attack: Node2D = lList_to_pick.pick_random()
	
	if pShooter == true: lEnemy_to_attack.shoot(lEnemy_to_attack.position)
		
	
	print("Damage:", lDamage, " to Enemy :", lEnemy_to_attack.character.health)
	
	if lCrit == true:
		if shaker.is_playing(): shaker.stop()
		else : shaker.start()
	
	lEnemy_to_attack.receive_damage(lDamage, lCrit)
	if lEnemy_to_attack.character.health <= 0:
		if shaker.is_playing(): shaker.stop()
		else : shaker.start()
		lList_to_pick.erase(lEnemy_to_attack)


func update_active_cookies(combat_cookies):
	for ally_node in spawned_allies:
		ally_node.character.receive_cookie_POWER(combat_cookies)


func win_anim_allies():
	var lTween = create_tween()
	for allies in spawned_allies:
		lTween.tween_property(allies, "position", enemies_spawn_pos.pick_random(), 4)
	area_ui.instance.hide()

func win_anim_allies2():
	var lTween = create_tween()
	for allies in spawned_allies:
		lTween.tween_property(allies, "position", enemies_spawn_pos2.pick_random(), 4)
	area_ui.instance.hide()

func spawn_ui():
	area_ui.instance.show()
	for enemies in spawned_enemies:
			enemies.attacking()
	for allies in spawned_allies:
			allies.attacking()

func wave2():
	area_ui.instance.show()
	for enemies in spawned_enemies2:
			enemies.attacking()
	for allies in spawned_allies:
			allies.attacking()
	shaker.targets.clear()
	shaker.origins.clear()
	shaker.targets.append(camera_2d)
	shaker.origins.append(camera_2d.position)

func wave3():
	area_ui.instance.show()
	for enemies in spawned_enemies3:
			enemies.attacking()
	for allies in spawned_allies:
			allies.attacking()
	shaker.targets.clear()
	shaker.origins.clear()
	shaker.targets.append(camera_2d)
	shaker.origins.append(camera_2d.position)


func lose():
	move_child(color_rect_2, get_children().size())
	color_rect_2.position = camera_2d.global_position - Vector2(color_rect_2.pivot_offset.x,color_rect_2.pivot_offset.y)
	area_ui.instance.hide()

func death_screen():
	move_child(but_retry, get_children().size())
	move_child(game_over, get_children().size())
	but_retry.position = camera_2d.position + Vector2(0,100) - Vector2(but_retry.pivot_offset.x,but_retry.pivot_offset.y)
	game_over.position = camera_2d.position - Vector2(0,100) - Vector2(game_over.pivot_offset.x,game_over.pivot_offset.y)
	var lTween = create_tween().set_parallel(true)
	lTween.tween_property(retry, "modulate:a", 1, 3)
	lTween.tween_property(game_over, "modulate:a", 1, 3)

func winning():
	for allies in spawned_allies:
		allies.animated_sprite.play("default")
	
	area_ui.instance.hide()

@onready var reward_1: Label = $ControlWin/PanelContainer/VBoxContainer/HBoxContainer/Reward1
@onready var reward_2: Label = $ControlWin/PanelContainer/VBoxContainer/HBoxContainer2/Reward2
@onready var special_texture: TextureRect = $ControlWin/PanelContainer/VBoxContainer/HBoxContainer2/TextureRect

func win_screen():
	move_child(control_win, get_children().size())
	var lGo_Down: Vector2 = Vector2(0,440)
	var lTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	lTween.tween_property(but_win, "position", but_win.position + lGo_Down,0.5)
	lTween.tween_property(panel_container, "position", panel_container.position + lGo_Down,0.5)
	lTween.tween_property(win, "position", win.position + lGo_Down,0.5)
	
	reward_1.text = str(level_reward1)+"X"
	reward_2.text = str(level_reward2)+"X"
	if level_reward2 < 1 : $ControlWin/PanelContainer/VBoxContainer/HBoxContainer2.hide()
	selected_special = Cookie.pick_random_special()
	special_texture.texture = Cookie.type_sprite(selected_special)

func _on_but_retry_pressed() -> void:
	Main.instance.queue_free()
	var lMain: Main = main_scene.instantiate()
	get_tree().root.add_child(lMain)

func _on_but_win_pressed() -> void:
	# mes yeux
	var tavern = get_parent().get_child(0)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	tavern.get_node("AnimationPlayer").play("RESET")
	
	var reward = {Cookie.TYPE.Normal: level_reward1, selected_special: level_reward2}
	tavern.update_after_victory(player_party,reward)
	
	queue_free()
