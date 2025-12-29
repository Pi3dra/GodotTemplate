extends Node2D

@onready var spawner: Node2D = $"../Spawners"

#region Party Spawning
func choose_random_char():
	return possibles_starter.pick_random()


func is_party_full() -> bool:
	return get_children().all(func(sprite: AnimatedSprite2D): return sprite.sprite_frames != null)


func clear_sprites():
	for sprite in get_children():
		sprite.sprite_frames = null


func spawn_party(party_info: Array[LogicalCharacter.TYPE]):
	clear_sprites()
	var party_slots = get_children()
	for i in range(party_info.size()):
		var slot: AnimatedSprite2D = party_slots[i]
		var char_type: LogicalCharacter.TYPE = party_info[i]
		slot.sprite_frames = Globals.get_character_data(char_type).animations
		slot.play("default")
#endregion

#region NPC Spawning

var possibles_starter: Array = [
	LogicalCharacter.TYPE.KNIGHT,
	LogicalCharacter.TYPE.WIZARD,
	LogicalCharacter.TYPE.FARMER,
	LogicalCharacter.TYPE.NECROMANCER,
	LogicalCharacter.TYPE.RANGER,
]
var pelo_tscn: PackedScene = load("res://Scenes/GameScene/tavern_char.tscn")
var buyable_char_nodes: Dictionary


func choose_chars(party_info: Array[LogicalCharacter.TYPE]) -> Array[LogicalCharacter.TYPE]:
	### TODO: this is supposed to not make
	var chars_not_picked_yet = possibles_starter.duplicate()

	for character in party_info:
		chars_not_picked_yet.erase(character)

	var characters_to_spawn: Array[LogicalCharacter.TYPE] = []

	for i in range(3):
		var spawn_enemy = randf() <= 0.75
		if spawn_enemy and not chars_not_picked_yet.is_empty():
			#TODO this seems to be generating a bug, somehow chars_not_picked_yet can be empty
			var character = chars_not_picked_yet.pick_random()
			chars_not_picked_yet.erase(character)
			characters_to_spawn.append(character)

	return characters_to_spawn


func spawn_character(character: LogicalCharacter.TYPE, char_position):
	var character_instance = pelo_tscn.instantiate()
	character_instance.call_deferred("init_char", character)
	character_instance.connect("buy_character", buy_character.bind(character_instance))
	buyable_char_nodes.set(character, character_instance)
	character_instance.global_position = char_position
	spawner.add_child(character_instance)


func spawn_characters(party_info) -> void:
	clear_all_npcs()
	var characters_to_spawn = choose_chars(party_info)
	var markers = spawner.get_children()
	var positions = markers.map(func(marker): return marker.position)
	for i in range(characters_to_spawn.size()):
		spawn_character(characters_to_spawn[i], positions[i])


func clear_all_npcs():
	for npc_instance in buyable_char_nodes.values():
		npc_instance.queue_free()
	buyable_char_nodes.clear()


func clear_npc(npc: LogicalCharacter.TYPE):
	if buyable_char_nodes.has(npc):
		buyable_char_nodes[npc].queue_free()
		buyable_char_nodes.erase(npc)


signal attempt_to_buy_char(character)


func buy_character(character):
	SoundManager.instance.play_sound("Click4", true, false)
	emit_signal("attempt_to_buy_char", character)
#endregion
