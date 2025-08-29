extends Node2D

@onready var enemies_spawners: Node2D = $EnemiesSpawners
@onready var ally_spawners: Node2D = $AllySpawners
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var char_scene: PackedScene = load("uid://b3y2sr2uweroy")

var chosen_enemies: Array[LogicalCharacter.TYPES]
var player_party: Array[LogicalCharacter.TYPES]
var spawned_enemies: Array[Node2D]
var spawned_allies: Array[Node2D]
var enemies_spawn_pos: Array[Vector2]
var allies_spawn_pos: Array[Vector2]


#//////////function//////////
func _init():
	area_ui.instance.connect("combat_cookies", update_active_cookies)
	


func _ready() -> void:
	get_parent().get_child(0).connect("pass_info_to_arena", get_tavern_info)
	
	animation_player.play("Opening")
	
	for pos: Marker2D in enemies_spawners.get_children():
		enemies_spawn_pos.append(pos.position)
	
	for pos: Marker2D in ally_spawners.get_children():
		allies_spawn_pos.append(pos.position)


func _on_visibility_changed() -> void:
	if visible == true: # This means that we leave the Tavern
		pass
	

func get_tavern_info(pWave_info, pParty_info):
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
	
	add_to_array(chosen_enemies, lEnnemies_par_wave[0], lWave_1)
	spawn_characters(chosen_enemies, enemies_spawn_pos, spawned_enemies)
	#endregion
	
	#For player party
	add_to_array(player_party, pParty_info.size(), pParty_info)
	spawn_characters(player_party, allies_spawn_pos, spawned_allies)


func spawn_characters(pStr_array: Array[LogicalCharacter.TYPES], pVec_array: Array[Vector2], pNode_array: Array[Node2D]):
	for characters in pStr_array:
		create_character(characters)
	
	for i in range(pVec_array.size()):
		if i < pNode_array.size():
			pNode_array[i].position = pVec_array[i] # Adjust the pos of enemies to avaible spawn pos


func add_to_array(pArray: Array, pNumb: int, pChar_name: Array):
	#pArray.clear()
	for i in range(pNumb):
		pArray.append(pChar_name[i])


func create_character(pChar_name: LogicalCharacter.TYPES):
	# Creation character Class (pas egal a character.tscn)
	var lDict: Dictionary = GameScene.pokedex.get(pChar_name) # lDict = the character(pChar_name) dictionary of stat
	var lChar: LogicalCharacter = LogicalCharacter.new(lDict["Health"], lDict["Damage"], lDict["Speed"], lDict["Crit"], lDict["Sprite"], lDict["Side"])
	# Instantiation of character tscn
	var lCharScene : Node2D = char_scene.instantiate()
	lCharScene.character = lChar # Attribution of the logical character to the physical tscn of character
	add_child(lCharScene)
	
	lCharScene.connect("attack", combat_handler) # Get the signal from character
	
	match lDict["Side"]:
		"Good":
			spawned_allies.append(lCharScene)
		"Bad":
			spawned_enemies.append(lCharScene)


func combat_handler(Attack_info : Array, pSide):
	var list_to_pick : Array[Node2D] = []
	
	var damage = Attack_info[0]
	var crit = Attack_info[1]
	
	match pSide:
		"Good":
			list_to_pick = spawned_enemies
		"Bad":
			list_to_pick = spawned_allies
			
	# TODO rajouter cas ou la liste est des allies ou des ennemis
	if list_to_pick == []:
		return
	
	var lEnemy_to_attack: Node2D = list_to_pick.pick_random()
	
	print("Damage:", damage, " to Enemy :", lEnemy_to_attack.character.health)
	
	lEnemy_to_attack.receive_damage(damage, crit)
	if lEnemy_to_attack.character.health <= 0:
		list_to_pick.erase(lEnemy_to_attack)


func update_active_cookies(combat_cookies):
	for ally_node in spawned_allies:
		ally_node.character.receive_cookie_POWER(combat_cookies)
