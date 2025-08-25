extends Node2D

@onready var enemies_spawners: Node2D = $EnemiesSpawners

var char_scene: PackedScene = load("uid://b3y2sr2uweroy")

var chosen_enemies: Array[String] = []
var player_party: Array[String] = []
var spawned_enemies: Array[Node2D] = []
var spawn_pos: Array[Vector2] = []

#//////////function//////////
func _init():
	hide()


func _ready() -> void:
	for pos: Marker2D in enemies_spawners.get_children():
		spawn_pos.append(pos.position)


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
		for enemies in chosen_enemies:
			create_character(enemies)
			
		for i in range(spawn_pos.size()): # Size of "spawn pos" array
			if i < spawned_enemies.size(): # Size of "spawned enemies' array
				spawned_enemies[i].position = spawn_pos[i] # Adjust the pos of enemies to avaible spawn pos
#endregion

func add_to_array(pArray: Array, pNumb: int, pChar_name: String):
	pArray.clear()
	for i in range(pNumb):
		pArray.append(pChar_name)


func create_character(pChar_name: String):
	# Creation character Class (pas egal a character.tscn)
	var lDict: Dictionary = GameScene.pokedex[pChar_name] # lDict = the character(pChar_name) dictionary of stat
	var lChar: LogicalCharacter = LogicalCharacter.new(lDict["Health"], lDict["Damage"], lDict["Speed"], lDict["Crit"], lDict["Sprite"])
	# Instantiation of character tscn
	var lCharScene : Node2D = char_scene.instantiate()
	lCharScene.character = lChar # Attribution of the logical character to the physical tscn of character

	spawned_enemies.append(lCharScene)
	add_child(lCharScene)
