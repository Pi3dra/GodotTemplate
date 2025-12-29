extends Node2D

# --- Nodes ---

@onready var ally_spawners: Node2D = $Spawners
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shaker: SimpleShaker = $Shaker
@onready var camera_2d: Camera2D = $Camera2D

@onready var player_spawners = $Spawners

# --- Scenes ---
var char_scene: PackedScene = load("uid://b3y2sr2uweroy")
var main_scene: PackedScene = load("uid://dsrw2guvcxik7")
var transition_scene: PackedScene = load("uid://bkjuff60yhtk0")
var win_scene: PackedScene = load("uid://1cnkhmktcngn")
var game_over_scene: PackedScene = load("uid://b43j4xlbwfwoo")

#all variables below are initialized inside the get_tavern_info function
var data: LevelData = null
# allies (separate)
var spawned_allies: Array = [] # Array[Node2D]
var spawned_enemies: Array = [] # Array[Array[Node2D]]
var all_pos_markers: Array = []
# This stores all marker group Node2Ds, to acces each individual marker call
# get_children()

#This is used to keep track of dead characters
#so they don't respawn in the tavern
var player_party: Array[LogicalCharacter.TYPE] = []

#region
func _ready() -> void:
	# Connexion pour recevoir les infos depuis le parent (Tavern)
	get_parent().get_child(0).connect("pass_info_to_arena", get_tavern_info)

	animation_player.play("WaveStart")
	var signal_mappings = {
		"combat_cookies": update_active_cookies,
		"tutorial_exit": quit_tutorial,
	}
	UI.manager.connect_to_caller(UI.NAME.ARENA, signal_mappings)


func get_tavern_info(level_data: Dictionary) -> void:
	data = level_data["LevelData"]

	var enemy_positions = _create_enemy_spawn_positions()
	spawned_enemies = _spawn_enemy_waves(enemy_positions)

	player_party = level_data["PartyInfo"]
	spawned_allies = _spawn_player_characters(player_party, player_spawners.get_children())

	all_pos_markers = [player_spawners]
	all_pos_markers.append_array(enemy_positions)

	_play_music(data.song)
#endregion

#region Spawning
func _create_enemy_spawn_positions() -> Array[Node2D]:
	var spawn_positions: Array[Node2D] = []
	for i in range(data.waves + 1):
		var new_spawners = player_spawners.duplicate()
		add_child(new_spawners)
		for child in new_spawners.get_children():
			child.position = Vector2(child.position.x + 400 * i, child.position.y)
		spawn_positions.append(new_spawners)
	spawn_positions.remove_at(0)
	return spawn_positions


# returns the enemy nodes inside 2D arrays per wave
func _spawn_enemy_waves(wave_nodes: Array[Node2D]):
	var waves = [] # Array[Array[Node2D]] <- these are the enemy nodes
	for wave_index in data.wave_data.size():
		var wave_markers = wave_nodes[wave_index].get_children()
		var enemy_wave = []
		for enemy in data.wave_data[wave_index]:
			var marker = wave_markers.pick_random()
			var enemy_instance = _spawn_char_on_marker(enemy, marker)
			enemy_wave.append(enemy_instance)
			wave_markers.erase(marker)
		waves.append(enemy_wave)

	return waves


func _spawn_player_characters(chars: Array[LogicalCharacter.TYPE], markers: Array[Node]):
	var player_nodes = []
	for character in chars:
		var marker = markers.pick_random()
		var player_instance = _spawn_char_on_marker(character, marker)
		markers.erase(marker)
		player_nodes.append(player_instance)
	return player_nodes


#Creates enemy, and moves it on top of the marker2D position , returns the character instance
func _spawn_char_on_marker(char_type: LogicalCharacter.TYPE, mark: Marker2D) -> Node2D:
	var character := LogicalCharacter.new(char_type)
	var char_instance = char_scene.instantiate()
	char_instance.character = character
	char_instance.call_deferred("update_lifebar")
	add_child(char_instance)
	char_instance.connect("attack", combat_handler)
	char_instance.position = mark.position
	return char_instance

#endregion

#region Level State Checking

func _check_wave_end(wave_index: int) -> void:
	# victory waves advanced pas the last one
	var enemies_list: Array = spawned_enemies[wave_index - 1]

	#level victory
	if enemies_list.is_empty() && wave_counter == data.waves:
		UI.manager.call_overlay(UI.NAME.WIN_SCREEN, self, data.rewards)
		_for_each_spawned(spawned_allies, "no_attacking")
		UI.manager.connect_to_caller(
			UI.NAME.WIN_SCREEN,
			{ "switch_to_tavern": level_victory },
		)
		return

	# cas défaite si plus d'alliés
	if spawned_allies.is_empty():
		UI.manager.call_overlay(UI.NAME.GAME_OVER, self)
		_for_each_spawned(enemies_list, "no_attacking")
		return

	# cas victoire pour la vague
	if enemies_list.is_empty():
		animation_player.play("WaveStart")
		_for_each_spawned(spawned_allies, "no_attacking")


# Goes back to tavern
func level_victory():
	var tavern = get_parent().get_child(0)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	tavern.animation_player.play("RESET")
	tavern.update_after_victory(player_party, data.rewards)
	queue_free()


# Helper pour appeler une méthode sur tous les nodes d'un tableau
func _for_each_spawned(nodes: Array, method_name: String) -> void:
	for n in nodes:
		if n and n.has_method(method_name):
			n.call(method_name)
#endregion

# TODO: Move this to level generation, this is dumb here!
func _play_music(songstr) -> void:
	SoundManager.instance.play_sound("Tavern", false)
	SoundManager.instance.play_sound(songstr, true, false)

#endregion

#region Combat Handling
#TODO break this up into mulitple funcs
signal drop_cookie(cookie: Cookie, drop_position: Vector2)


func shake_camera_if(condition : bool):
	if condition:
		shake()
		
func shake():
		if shaker.is_playing():
			shaker.stop()
		else:
			shaker.start()

func combat_handler(attack_info: Array, side, shooter, char_self) -> void:
	var damage = attack_info[0]
	var crit = attack_info[1]
	var list_to_pick: Array = []

	if side == LogicalCharacter.SIDE.GOOD:
		list_to_pick = spawned_enemies[clamp(wave_counter - 1, 0, 8)]
	elif side == LogicalCharacter.SIDE.BAD:
		list_to_pick = spawned_allies

	if list_to_pick.is_empty():
		return

	var enemy_to_attack: Node2D = list_to_pick.pick_random()
	if shooter == true:
		char_self.shoot(enemy_to_attack.position, char_self.character.type)

	# Crit shake
	shake_camera_if(crit)
	enemy_to_attack.receive_damage(damage, crit)

	# Gestion de la mort
	if enemy_to_attack.character.health <= 0:
		shake()
		if enemy_to_attack.character.side == LogicalCharacter.SIDE.BAD:
			print("SHOULD DROP COOKIE")
			_drop_cookie_on_kill(enemy_to_attack)

		# si c'est un allié tué, l'enlever de la player_party
		if side == LogicalCharacter.SIDE.BAD:
			player_party.erase(enemy_to_attack.character.type)

		# enlever l'instance du tableau de la vague appropriée ou des alliés
		_remove_node_from_spawn_lists(enemy_to_attack)
		_check_wave_end(wave_counter)

# TODO: Make this just put the cookie in the bar instead of leaving it on the ground
# also make it editable in the  editor the amount of cookies dropped and the chances
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
	for i in data.waves:
		if spawned_enemies[i].has(node):
			spawned_enemies[i].erase(node)
			return
	if spawned_allies.has(node):
		spawned_allies.erase(node)
		
func update_active_cookies(combat_cookies, _enemy) -> void:
	for ally_node in spawned_allies:
		ally_node.character.receive_cookie_power(combat_cookies)
#endregion



#region Animation Between Waves

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
	UI.manager.show_overlay(UI.NAME.ARENA)
	_for_each_spawned(spawned_enemies[wave_counter], "attacking")
	_for_each_spawned(spawned_allies, "attacking")
	_setup_shaker_for_camera()
	wave_counter += 1


func move_players():
	if not camera_x_pos:
		camera_x_pos = camera_2d.position.x
	if wave_counter > 0:
		camera_x_pos = camera_x_pos + (get_viewport_rect().size.x * 0.25)
		var target_pos: Vector2 = Vector2(camera_x_pos, camera_2d.position.y)
		move_camera(target_pos)
		var tween = create_tween().set_parallel(true)

		#Move char to rangom position
		var possible_positions = all_pos_markers[wave_counter].get_children()
		for char_instance in spawned_allies:
			var chosen_marker = possible_positions.pick_random()
			possible_positions.erase(chosen_marker)
			var pos = chosen_marker.position
			tween.tween_property(char_instance, "position", pos, 4)

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
	tavern.get_node("AnimationPlayer").play("RESET")
	SoundManager.instance.play_sound("SONG3", false)
	SoundManager.instance.play_sound("Tavern", true)
	queue_free()
#endregion
