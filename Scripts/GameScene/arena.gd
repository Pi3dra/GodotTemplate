extends Node2D

@onready var enemies_spawners: Node2D = $EnemiesSpawners
@onready var ally_spawners: Node2D = $AllySpawners


var char_scene: PackedScene = load("uid://b3y2sr2uweroy")

var chosen_enemies: Array[String]
var player_party: Array[String]
var spawned_enemies: Array[Node2D]
var spawned_allies: Array[Node2D]
var enemies_spawn_pos: Array[Vector2]
var allies_spawn_pos: Array[Vector2]


#//////////function//////////
func _init():
	hide()
	#area_ui.instance.connect("combat_cookies", update_active_cookies)


func _ready() -> void:
	for pos: Marker2D in enemies_spawners.get_children():
		enemies_spawn_pos.append(pos.position)
	
	for pos: Marker2D in ally_spawners.get_children():
		allies_spawn_pos.append(pos.position)


func _process(delta: float) -> void:
	pass

#region Signals
func _on_skeleton_pressed() -> void:
	add_to_array(chosen_enemies, 1, "Skeleton")


func _on_skeletonx_3_pressed() -> void:
	add_to_array(chosen_enemies, 3, "Skeleton")


func _on_goblinx_2_pressed() -> void:
	add_to_array(chosen_enemies, 2, "Goblin")


func _on_knight_pressed() -> void:
	add_to_array(player_party, 1, "Knight")


func _on_knightx_2_pressed() -> void:
	add_to_array(player_party, 2, "Knight")


func _on_knightx_3_pressed() -> void:
	add_to_array(player_party, 3, "Knight")


func _on_visibility_changed() -> void:
	if visible == true: # This means that we leave the Tavern
		spawn_characters(chosen_enemies, enemies_spawn_pos, spawned_enemies)
		spawn_characters(player_party, allies_spawn_pos, spawned_allies)
	
	place_camera()
	
#endregion


func place_camera():
	var lCam: Camera2D = Camera2D.new()
	var lZoom: Vector2 = Vector2(1.5, 1.5)
	var lPos: Vector2 = Vector2(654.0, 547.0)
	lCam.zoom = lZoom
	lCam.position = lPos
	add_child(lCam)


func spawn_characters(pStr_array: Array[String], pVec_array: Array[Vector2], pNode_array: Array[Node2D]):
	for characters in pStr_array:
		create_character(characters)
	
	for i in range(pVec_array.size()):
		if i < pNode_array.size():
			pNode_array[i].position = pVec_array[i] # Adjust the pos of enemies to avaible spawn pos


func add_to_array(pArray: Array, pNumb: int, pChar_name: String):
	pArray.clear()
	for i in range(pNumb):
		pArray.append(pChar_name)


func create_character(pChar_name: String):
	# Creation character Class (pas egal a character.tscn)
	var lDict: Dictionary = GameScene.pokedex[pChar_name] # lDict = the character(pChar_name) dictionary of stat
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


func combat_handler(pDamage, pSide):
	var list_to_pick : Array[Node2D] = []
	
	match pSide:
		"Good":
			list_to_pick = spawned_enemies
		"Bad":
			list_to_pick = spawned_allies
			
	# TODO rajouter cas ou la liste est des allies ou des ennemis
	if list_to_pick == []:
		return
	
	var lEnemy_to_attack: Node2D = list_to_pick.pick_random()
	
	print("Damage:", pDamage, " to Enemy :", lEnemy_to_attack.character.health)
	
	lEnemy_to_attack.receive_damage(pDamage)
	if lEnemy_to_attack.character.health <= 0:
		list_to_pick.erase(lEnemy_to_attack)


#func update_active_cookies(combat_cookies):
#	print("Cookies Received, Over")
#	for cookie in combat_cookies:
#		for ally_node in spawned_allies:
#			ally_node.character.append(cookie)
