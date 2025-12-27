extends Node2D

# --- Nodes ---
@onready var enemies_spawners_nodes: Array[Node2D] = [
	$EnemiesSpawners,
	$EnemiesSpawners2,
	$EnemiesSpawner3,
]
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
var chosen_enemies: Array = [[], [], []] # Array[Array[LogicalCharacter.TYPE]]
var spawn_positions: Array = [[], [], []] # Array[Array[Vector2]]
# spawned[0] = enemies wave1, spawned[1] = wave2, spawned[2] = wave3
var spawned: Array = [[], [], []]

# allies (separate)
var player_party: Array = [] # Array[LogicalCharacter.TYPE]
var spawned_allies: Array = [] # Array[Node2D]
var allies_spawn_pos: Array = [] # Array[Vector2]

# max per wave
var max_wave: Array[int] = [0, 0, 0]

# flags pour arrêter le process pour chaque vague
var wave_stopped: Array[bool] = [false, false, false]
var rewards

# rewards & selection

var selected_special

# ------------------------
# Signals / Init
# ------------------------
#region
func _ready() -> void:
	# Connexion pour recevoir les infos depuis le parent (Tavern)
	get_parent().get_child(0).connect("pass_info_to_arena", get_tavern_info)

	animation_player.play("WaveStart")

	# Remplir les positions d'apparition ennemies
	_fill_spawn_positions()

	# Remplir les positions alliées
	for m in ally_spawners.get_children():
		if m is Marker2D:
			allies_spawn_pos.append(m.position)

	var signal_mappings = {
		"combat_cookies": update_active_cookies,
		"tutorial_exit": quit_tutorial,
	}
	UI.manager.connect_to_caller(UI.NAME.ARENA, signal_mappings)


# Remplit spawn_positions à partir de enemies_spawners_nodes
func _fill_spawn_positions() -> void:
	for i in enemies_spawners_nodes.size():
		var spawner = enemies_spawners_nodes[i]
		for child in spawner.get_children():
			if child is Marker2D:
				spawn_positions[i].append(child.position)
#endregion
# ------------------------
# Process (vérification des fins de vague)
# ------------------------
#region
func _process(_delta: float) -> void:
	for wave_index in range(3):
		_check_wave_end(wave_index)


# Vérifie l'état d'une vague :
# si plus d'ennemis -> joue Ending/Ending2/Win et arrête alliés
# si plus d'alliés -> Lose et arrête ennemis de la vague
func _check_wave_end(wave_index: int) -> void:
	if wave_stopped[wave_index]:
		return

	var enemies_list: Array = spawned[wave_index]
	# cas victoire pour la vague
	if enemies_list.is_empty():
		match wave_index:
			0:
				animation_player.play("WaveStart")
			1:
				animation_player.play("WaveStart")
			2:
				UI.manager.call_overlay(UI.NAME.WIN_SCREEN, self, rewards)
				UI.manager.connect_to_caller(
					UI.NAME.WIN_SCREEN,
					{ "switch_to_tavern": level_victory },
				)

		wave_stopped[wave_index] = true
		_for_each_spawned(spawned_allies, "no_attacking")
		return

	# cas défaite si plus d'alliés
	if spawned_allies.is_empty():
		UI.manager.call_overlay(UI.NAME.GAME_OVER, self)
		wave_stopped[wave_index] = true
		_for_each_spawned(enemies_list, "no_attacking")
		return


# Goes back to tavern
func level_victory():
	var tavern = get_parent().get_child(0)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	tavern.animation_player.play("RESET")
	tavern.update_after_victory(player_party, rewards)
	queue_free()


# Helper pour appeler une méthode sur tous les nodes d'un tableau
func _for_each_spawned(nodes: Array, method_name: String) -> void:
	for n in nodes:
		if n and n.has_method(method_name):
			n.call(method_name)
#endregion
# ------------------------
# Recevoir les données du Tavern et initialiser la scène
# ------------------------
#region
func get_tavern_info(level_data: Dictionary) -> void:
	var wave_info = level_data["WaveInfo"]
	var party_info = level_data["PartyInfo"]
	rewards = level_data["Rewards"]

	# pWave_info attend 3 arrays (une par vague)
	for i in range(3):
		var wave_arr = wave_info[i]
		chosen_enemies[i] = wave_arr.duplicate()
		max_wave[i] = wave_arr.size()

	# Spawn ennemis par vague
	for i in range(3):
		spawn_characters_for_wave(i)

	# Récompenses et équipe du joueur

	player_party = party_info.duplicate()
	spawn_characters_allies(player_party)

	# Choix musique selon la 1ère vague
	_play_music_for_wave0(wave_info[0])


# TODO: Move this to level generation, this is dumb here!
func _play_music_for_wave0(wave_1: Array) -> void:
	SoundManager.instance.play_sound("Tavern", false)
	if (wave_1.has(LogicalCharacter.TYPE.SLIME) or
		wave_1.has(LogicalCharacter.TYPE.SKELETON) or
		wave_1.has(LogicalCharacter.TYPE.SPIDER) ):
		SoundManager.instance.play_sound("Level1", true, false)
	elif (wave_1.has(LogicalCharacter.TYPE.WITCH) or
		wave_1.has(LogicalCharacter.TYPE.GOBLIN) or
		wave_1.has(LogicalCharacter.TYPE.ORC) ):
		SoundManager.instance.play_sound("Level2", true, false)
	else:
		SoundManager.instance.play_sound("Level3", true, false)
#endregion
# ------------------------
# Spawning
# ------------------------
#region
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


#TODO: Why we use char_scene2 instead of char_scene?
# Crée un personnage et l'ajoute au bon tableau (wave_index pour "Bad", allies pour "Good")
func _create_character_for_wave(char_type: LogicalCharacter.TYPE, wave_index: int) -> void:
	var character := LogicalCharacter.new(char_type)
	var char_scene2: Node2D = char_scene.instantiate()
	char_scene2.character = character
	char_scene2.call_deferred("update_lifebar")
	add_child(char_scene2)
	char_scene2.connect("attack", combat_handler)

	# Ajout selon le Side
	match character.side:
		LogicalCharacter.SIDE.GOOD:
			spawned_allies.append(char_scene2)
		LogicalCharacter.SIDE.BAD:
			spawned[wave_index].append(char_scene2)


# Pour les alliés (utilisé si on veut explicitement spawn des alliés)
func _create_character_for_ally(char_type: LogicalCharacter.TYPE) -> void:
	var character := LogicalCharacter.new(char_type)
	var char_scene2: Node2D = char_scene.instantiate()
	char_scene2.character = character
	char_scene2.call_deferred("update_lifebar")
	add_child(char_scene2)
	char_scene2.connect("attack", combat_handler)
	spawned_allies.append(char_scene2)
#endregion
# ------------------------
# Combat handler
# ------------------------

#TODO break this up into mulitple funcs
signal drop_cookie(cookie: Cookie, drop_position: Vector2)


func combat_handler(attack_info: Array, side, shooter, char_self) -> void:
	var damage = attack_info[0]
	var crit = attack_info[1]
	var list_to_pick: Array = []

	if side == LogicalCharacter.SIDE.GOOD:
		# priorités : wave0 -> wave1 -> wave2
		if not spawned[0].is_empty():
			list_to_pick = spawned[0]
		elif not spawned[1].is_empty():
			list_to_pick = spawned[1]
		elif not spawned[2].is_empty():
			list_to_pick = spawned[2]
	elif side == LogicalCharacter.SIDE.BAD:
		list_to_pick = spawned_allies

	if list_to_pick.is_empty():
		return

	var enemy_to_attack: Node2D = list_to_pick.pick_random()
	if shooter == true:
		#TODO: Is this really needed to use char_self?
		char_self.shoot(enemy_to_attack.position, char_self.character.type)

	# Crit shake
	if crit:
		if shaker.is_playing():
			shaker.stop()
		else:
			shaker.start()

	enemy_to_attack.receive_damage(damage, crit)

	# Gestion de la mort
	if enemy_to_attack.character.health <= 0:
		if enemy_to_attack.character.side == LogicalCharacter.SIDE.BAD:
			_drop_cookie_on_kill(enemy_to_attack)
		# shake on death

		if shaker.is_playing():
			shaker.stop()
		else:
			shaker.start()

		# si c'est un allié tué, l'enlever de la player_party
		if side == LogicalCharacter.SIDE.BAD:
			player_party.erase(enemy_to_attack.character.type)

		# enlever l'instance du tableau de la vague appropriée ou des alliés
		_remove_node_from_spawn_lists(enemy_to_attack)


func _drop_cookie_on_kill(enemy: Node2D) -> void:
	var enemy_pos: Vector2 = enemy.get_global_transform_with_canvas().get_origin()
	var final_pos = enemy_pos - Vector2(32, 32)
	var random_cookie: Cookie.TYPE
	if randf() > 0.8:
		random_cookie = Cookie.pick_random_special()
	else:
		random_cookie = Cookie.TYPE.NORMAL
	emit_signal("drop_cookie", random_cookie, final_pos)


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
func update_active_cookies(combat_cookies, _enemy) -> void:
	for ally_node in spawned_allies:
		ally_node.character.receive_cookie_power(combat_cookies)

# ------------------------
# Animations & UI helpers
# ------------------------
# These are called by AnimationPlayer in arena
#region

# REFACTORED CODE
var wave_counter: int = 0
var camera_tween: Tween
var camera_x_pos: float


func move_camera(target_pos: Vector2):
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()

	camera_tween = create_tween()
	camera_tween.tween_property(
		camera_2d,
		"position",
		target_pos,
		4.0,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func update_wave():
	print("Called Update")
	UI.manager.show_overlay(UI.NAME.ARENA)
	_for_each_spawned(spawned[wave_counter], "attacking")
	_for_each_spawned(spawned_allies, "attacking")
	_setup_shaker_for_camera()
	wave_counter += 1


func move_players():
	print("Called Move")
	if not camera_x_pos:
		camera_x_pos = camera_2d.position.x
	if wave_counter > 0:
		camera_x_pos = camera_x_pos + (get_viewport_rect().size.x * 0.25)
		var target_pos: Vector2 = Vector2(camera_x_pos, camera_2d.position.y)
		move_camera(target_pos)
		var tween = create_tween().set_parallel(true)
		for i in range(min(spawned_allies.size(), spawn_positions[0].size())):
			var ally = spawned_allies[i]
			var pos = spawn_positions[wave_counter - 1][i]
			tween.tween_property(ally, "position", pos, 4)

# ================


func _setup_shaker_for_camera() -> void:
	shaker.targets.clear()
	shaker.origins.clear()
	shaker.targets.append(camera_2d)
	shaker.origins.append(camera_2d.position)


func quit_tutorial() -> void:
	var tavern = get_parent().get_child(0)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	#tavern.get_node("AnimationPlayer").play("RESET")
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Tavern", true)
	queue_free()
#endregion
