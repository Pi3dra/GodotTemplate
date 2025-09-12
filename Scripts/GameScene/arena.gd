extends Node2D

# --- Nodes ---
@onready var enemies_spawners_nodes: Array[Node2D] = [$EnemiesSpawners, $EnemiesSpawners2, $EnemiesSpawner3]
@onready var ally_spawners: Node2D = $AllySpawners
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shaker: SimpleShaker = $Shaker
@onready var camera_2d: Camera2D = $Camera2D


# --- Scenes ---
var char_scene: PackedScene = load("uid://b3y2sr2uweroy")
var main_scene: PackedScene = load("uid://dsrw2guvcxik7")
var transition_scene: PackedScene = load("uid://bkjuff60yhtk0")
var win_scene: PackedScene = load("uid://1cnkhmktcngn")
var game_over_scene: PackedScene = load("uid://b43j4xlbwfwoo")

# --- Data structures (indexed by wave 0..2) ---
var chosen_enemies: Array = [[], [], []]                # Array[Array[LogicalCharacter.TYPE]]
var spawn_positions: Array = [[], [], []]              # Array[Array[Vector2]]
var spawned: Array = [[], [], []]                      # spawned[0] = enemies wave1, spawned[1] = wave2, spawned[2] = wave3

# allies (separate)
var player_party: Array = []                           # Array[LogicalCharacter.TYPE]
var spawned_allies: Array = []                         # Array[Node2D]
var allies_spawn_pos: Array = []                       # Array[Vector2]

# max per wave
var max_wave: Array[int] = [0, 0, 0]

# flags pour arrêter le process pour chaque vague
var wave_stopped: Array[bool] = [false, false, false]

# rewards & selection
var level_reward1: int = 0
var level_reward2: int = 0
var selected_special

# ------------------------
# Signals / Init
# ------------------------

func _ready() -> void:
	# Connexion pour recevoir les infos depuis le parent (Tavern)
	get_parent().get_child(0).connect("pass_info_to_arena", get_tavern_info)
	animation_player.play("Opening")

	# Remplir les positions d'apparition ennemies
	_fill_spawn_positions()

	# Remplir les positions alliées
	for m in ally_spawners.get_children():
		if m is Marker2D:
			allies_spawn_pos.append(m.position)
			
	
	var signal_mappings = {
		"combat_cookies" : update_active_cookies,
		"tutorial_exit" : quit_tutorial,
	}
	UI.manager.connect_to_caller(UI.NAME.Arena, signal_mappings)

# Remplit spawn_positions à partir de enemies_spawners_nodes
func _fill_spawn_positions() -> void:
	for i in enemies_spawners_nodes.size():
		var spawner = enemies_spawners_nodes[i]
		for child in spawner.get_children():
			if child is Marker2D:
				spawn_positions[i].append(child.position)

# ------------------------
# Process (vérification des fins de vague)
# ------------------------
func _process(_delta: float) -> void:
	for wave_index in range(3):
		_check_wave_end(wave_index)

# Vérifie l'état d'une vague : si plus d'ennemis -> joue Ending/Ending2/Win et arrête alliés ; si plus d'alliés -> Lose et arrête ennemis de la vague
func _check_wave_end(wave_index: int) -> void:
	if wave_stopped[wave_index]:
		return

	var enemies_list: Array = spawned[wave_index]
	# cas victoire pour la vague
	if enemies_list.is_empty():
		match wave_index:
			0:
				animation_player.play("Ending")
			1:
				animation_player.play("Ending2")
			2:
				UI.manager.call_overlay(UI.NAME.WinScreen, self)
				UI.manager.connect_to_caller(UI.NAME.WinScreen,{"switch_to_tavern":level_victory})
		
		wave_stopped[wave_index] = true
		_for_each_spawned(spawned_allies, "no_attacking")
		return

	# cas défaite si plus d'alliés
	if spawned_allies.is_empty():
		UI.manager.call_overlay(UI.NAME.GameOver, self)
		wave_stopped[wave_index] = true
		_for_each_spawned(enemies_list, "no_attacking")
		return
# Goes back to tavern
func level_victory():
	var tavern = get_parent().get_child(0)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	tavern.get_node("AnimationPlayer").play("RESET")
	queue_free()

# Helper pour appeler une méthode sur tous les nodes d'un tableau
func _for_each_spawned(nodes: Array, method_name: String) -> void:
	for n in nodes:
		if n and n.has_method(method_name):
			n.call(method_name)

# ------------------------
# Recevoir les données du Tavern et initialiser la scène
# ------------------------
func get_tavern_info(level_data : Dictionary) -> void:
	var pWave_info = level_data["WaveInfo"]
	var pParty_info = level_data["PartyInfo"]
	var reward1 = level_data["Rewards"].values()[0]
	var reward2 = level_data["Rewards"].values()[1]
	
	# pWave_info attend 3 arrays (une par vague)
	for i in range(3):
		var wave_arr = pWave_info[i]
		chosen_enemies[i] = wave_arr.duplicate()
		max_wave[i] = wave_arr.size()

	# Spawn ennemis par vague
	for i in range(3):
		spawn_characters_for_wave(i)

	# Récompenses et équipe du joueur
	level_reward1 = reward1
	level_reward2 = reward2
	player_party = pParty_info.duplicate()
	spawn_characters_allies(player_party)

	# Choix musique selon la 1ère vague
	_play_music_for_wave0(pWave_info[0])

func _play_music_for_wave0(lWave_1: Array) -> void:
	SoundManager.instance.play_sound("Tavern", false)
	if lWave_1.has(LogicalCharacter.TYPE.Slime) or lWave_1.has(LogicalCharacter.TYPE.Skeleton) or lWave_1.has(LogicalCharacter.TYPE.Spider):
		SoundManager.instance.play_sound("Level1", true, false)
	elif lWave_1.has(LogicalCharacter.TYPE.Witch) or lWave_1.has(LogicalCharacter.TYPE.Goblin) or lWave_1.has(LogicalCharacter.TYPE.Orc):
		SoundManager.instance.play_sound("Level2", true, false)
	else:
		SoundManager.instance.play_sound("Level3", true, false)

# ------------------------
# Spawning
# ------------------------
# Spawn des ennemis pour une vague indiquée (0..2)
func spawn_characters_for_wave(wave_index: int) -> void:
	var list_types: Array = chosen_enemies[wave_index]
	for t in list_types:
		_create_character_for_wave(t, wave_index)

	# Positionne les nodes instanciés sur les spawn points disponibles
	for i in range(spawn_positions[wave_index].size()):
		if i < spawned[wave_index].size():
			spawned[wave_index][i].position = spawn_positions[wave_index][i]

	# S'assurer que tout commence en "no_attacking"
	_for_each_spawned(spawned_allies, "no_attacking")
	for w in range(3):
		_for_each_spawned(spawned[w], "no_attacking")

	# garder color_rect en dernier plan visuel
	#move_child(color_rect, get_children().size())

# Spawn des alliés (player party)
func spawn_characters_allies(party_types: Array) -> void:
	for t in party_types:
		_create_character_for_ally(t)

	for i in range(allies_spawn_pos.size()):
		if i < spawned_allies.size():
			spawned_allies[i].position = allies_spawn_pos[i]
	_for_each_spawned(spawned_allies, "no_attacking")

# Crée un personnage et l'ajoute au bon tableau (wave_index pour "Bad", allies pour "Good")
func _create_character_for_wave(pChar_type: LogicalCharacter.TYPE, wave_index: int) -> void:
	var lChar := LogicalCharacter.new(pChar_type)
	var lCharScene: Node2D = char_scene.instantiate()
	lCharScene.character = lChar
	lCharScene.call_deferred("update_lifebar")
	add_child(lCharScene)
	lCharScene.connect("attack", combat_handler)

	# Ajout selon le Side
	match lChar.side:
		LogicalCharacter.SIDE.Good:
			spawned_allies.append(lCharScene)
		LogicalCharacter.SIDE.Bad:
			spawned[wave_index].append(lCharScene)

# Pour les alliés (utilisé si on veut explicitement spawn des alliés)
func _create_character_for_ally(pChar_type: LogicalCharacter.TYPE) -> void:
	var lChar := LogicalCharacter.new(pChar_type)
	var lCharScene: Node2D = char_scene.instantiate()
	lCharScene.character = lChar
	lCharScene.call_deferred("update_lifebar")
	add_child(lCharScene)
	lCharScene.connect("attack", combat_handler)
	spawned_allies.append(lCharScene)

# ------------------------
# Combat handler
# ------------------------

#TODO break this up into mulitple funcs
signal drop_cookie(cookie : Cookie, drop_position : Vector2)
func combat_handler(Attack_info: Array, pSide, pShooter, pSelf) -> void:
	var lDamage = Attack_info[0]
	var lCrit = Attack_info[1]
	var lList_to_pick: Array = []

	if pSide == LogicalCharacter.SIDE.Good:
		# priorités : wave0 -> wave1 -> wave2
		if not spawned[0].is_empty():
			lList_to_pick = spawned[0]
		elif not spawned[1].is_empty():
			lList_to_pick = spawned[1]
		elif not spawned[2].is_empty():
			lList_to_pick = spawned[2]
	elif pSide == LogicalCharacter.SIDE.Bad:
		lList_to_pick = spawned_allies

	if lList_to_pick.is_empty():
		return

	var lEnemy_to_attack: Node2D = lList_to_pick.pick_random()
	if pShooter == true:
		pSelf.shoot(lEnemy_to_attack.position, pSelf.character.type)

	# Crit shake
	if lCrit:
		if shaker.is_playing():
			shaker.stop()
		else:
			shaker.start()

	lEnemy_to_attack.receive_damage(lDamage, lCrit)

	# Gestion de la mort
	if lEnemy_to_attack.character.health <= 0:
		if lEnemy_to_attack.character.side == LogicalCharacter.SIDE.Bad:
			# position écran correcte
			# FOUND this in an old forum, only god knows how it works
			var enemy_pos : Vector2 = lEnemy_to_attack.get_global_transform_with_canvas().get_origin()
			var final_pos = enemy_pos - Vector2(32,32)
			var random_cookie : Cookie.TYPE
			if randf() > 0.8:
				random_cookie = Cookie.pick_random_special()
			else:
				random_cookie = Cookie.TYPE.Normal
			emit_signal("drop_cookie",random_cookie, final_pos )

		# shake on death
		if shaker.is_playing():
			shaker.stop()
		else:
			shaker.start()

		# si c'est un allié tué, l'enlever de la player_party
		if pSide == LogicalCharacter.SIDE.Bad:
			player_party.erase(lEnemy_to_attack.character.type)

		# enlever l'instance du tableau de la vague appropriée ou des alliés
		_remove_node_from_spawn_lists(lEnemy_to_attack)

# Enlève un node des tableaux spawnés (vagues ou alliés)
func _remove_node_from_spawn_lists(node: Node2D) -> void:
	for i in range(3):
		if spawned[i].has(node):
			spawned[i].erase(node)
			return
	if spawned_allies.has(node):
		spawned_allies.erase(node)

# ------------------------
# Cookies / buffs
# ------------------------
# Si enemy == true, on ajoute aux ennemis actifs (vérifie vagues dans l'ordre). Sinon aux alliés.
func update_active_cookies(combat_cookies, enemy) -> void:
	if enemy:
		for i in range(3):
			if not spawned[i].is_empty():
				for enemy_node in spawned[i]:
					enemy_node.character.receive_cookie_POWER(combat_cookies)
				return
	else:
		for ally_node in spawned_allies:
			ally_node.character.receive_cookie_POWER(combat_cookies)

# ------------------------
# Animations & UI helpers
# ------------------------
func win_anim_allies() -> void:
	var lTween = create_tween().set_parallel(true)
	for i in range(min(spawned_allies.size(), spawn_positions[0].size())):
		var ally = spawned_allies[i]
		var pos = spawn_positions[0][i]
		lTween.tween_property(ally, "position", pos, 4)

func win_anim_allies2() -> void:
	var lTween = create_tween().set_parallel(true)
	for i in range(min(spawned_allies.size(), spawn_positions[0].size())):
		var ally = spawned_allies[i]
		var pos = spawn_positions[1][i]
		lTween.tween_property(ally, "position", pos, 4)

func spawn_ui() -> void:
	UI.manager.show_overlay(UI.NAME.Arena)
	_for_each_spawned(spawned[0], "attacking")
	_for_each_spawned(spawned_allies, "attacking")

func wave2() -> void:
	UI.manager.show_overlay(UI.NAME.Arena)
	_for_each_spawned(spawned[1], "attacking")
	_for_each_spawned(spawned_allies, "attacking")
	_setup_shaker_for_camera()

func wave3() -> void:
	UI.manager.show_overlay(UI.NAME.Arena)
	_for_each_spawned(spawned[2], "attacking")
	_for_each_spawned(spawned_allies, "attacking")
	_setup_shaker_for_camera()

func _setup_shaker_for_camera() -> void:
	shaker.targets.clear()
	shaker.origins.clear()
	shaker.targets.append(camera_2d)
	shaker.origins.append(camera_2d.position)


func quit_tutorial() -> void:
	var tavern = get_parent().get_child(0)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	tavern.get_node("AnimationPlayer").play("RESET")
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Tavern", true)
	queue_free()
