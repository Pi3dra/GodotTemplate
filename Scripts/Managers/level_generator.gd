class_name LevelData

# Actually used data
var waves: int
var total_enemies: int
var max_enemies_per_wave: int
var level_difficulty: Difficulty
var song: String

var wave_data = [] # Array[Array[Enemy.TYPE]]
var rewards: Dictionary[Cookie.TYPE, int]

#Data for generation
enum Difficulty { EASY, MEDIUM, HARD }
enum Songs {
	SONG1,
	SONG2,
	SONG3,
}

var easy_enemies = [
	LogicalCharacter.TYPE.SKELETON,
	LogicalCharacter.TYPE.SLIME,
	LogicalCharacter.TYPE.SPIDER,
]
var medium_enemies = [
	LogicalCharacter.TYPE.ORC,
	LogicalCharacter.TYPE.WITCH,
	LogicalCharacter.TYPE.GOBLIN,
]
var hard_enemies = [
	LogicalCharacter.TYPE.CYCLOP,
	LogicalCharacter.TYPE.DEVIL,
	LogicalCharacter.TYPE.DRAGON,
] # Rajouter un nouveau à la place du dragon

var enemy_palette = {
	Difficulty.EASY: easy_enemies,
	Difficulty.MEDIUM: medium_enemies,
	Difficulty.HARD: hard_enemies,
}


func _init(difficulty: Difficulty):
	generate_level(difficulty)


func generate_level(difficulty: Difficulty):
	level_difficulty = difficulty
	var cookies = 0
	var special_cookies = 0

	match difficulty:
		Difficulty.HARD:
			waves = randi() % 3 + 4
			total_enemies = waves * (randi() % 1 + 5)
			max_enemies_per_wave = 6
			song = Songs.keys()[Songs.SONG1]
			cookies = 60 + randi() % 6
			special_cookies = 5 + randi() % 2
		Difficulty.MEDIUM:
			waves = randi() % 2 + 3
			total_enemies = waves * (randi() % 2 + 2)
			max_enemies_per_wave = 5
			song = Songs.keys()[Songs.SONG2]
			cookies = 30 + randi() % 3
			special_cookies = 3 + randi() % 2
		Difficulty.EASY:
			waves = randi() % 1 + 2
			total_enemies = waves * (randi() % 2 + 1)
			max_enemies_per_wave = 3
			song = Songs.keys()[Songs.SONG3]
			cookies = 20 + randi() % 3
			special_cookies = 0

	generate_reward(cookies, special_cookies)
	generate_waves()
	#var waves_distribution: Array = distribute_enemies(used_enemies)


func generate_reward(cookies: int, special_cookies: int):
	rewards.set(Cookie.TYPE.NORMAL, cookies)
	if special_cookies < 4 && special_cookies > 0:
		rewards.set(Cookie.pick_random_special(), special_cookies)
	else:
		var split_into = randi() % 2 + 2
		var distribution = LevelData.random_positive_ints_sum_to_x(split_into, special_cookies)
		var already_used_cookies: Array[Cookie.TYPE] = []
		for number_of_cookies in distribution:
			var special_cookie = Cookie.pick_random_special_not_in(already_used_cookies)
			if number_of_cookies > 0:
				rewards.set(special_cookie, number_of_cookies)
				already_used_cookies.append(special_cookie)


func generate_waves(): #returns Array[Array[Enemy.TYPE]]
	#we should change the max here
	var wave_distribution = LevelData.random_positive_ints_sum_to_x_with_max(waves, total_enemies, max_enemies_per_wave) # We cap to 6 enemies per wave

	for enemies_per_wave in wave_distribution:
		var enemy_types_number = enemy_palette[level_difficulty].size()
		var enemy_distribution = random_nonnegative_ints_sum_to_x(enemy_types_number, enemies_per_wave)

		var single_wave = []
		for enemy_idx in range(enemy_types_number):
			var enemy_type = enemy_palette[level_difficulty][enemy_idx]
			var enemy_count = enemy_distribution[enemy_idx]
			var enemy_arr = []
			enemy_arr.resize(enemy_count)
			enemy_arr.fill(enemy_type)
			single_wave.append_array(enemy_arr)
		wave_data.append(single_wave)


static func random_positive_ints_sum_to_x(n: int, x: int) -> Array:
	if n <= 0 or x < n:
		return []

	var remaining := x - n # reserve 1 for each
	var cuts := []

	# generate n-1 random cut points between 0 and remaining
	for i in range(n - 1):
		cuts.append(randi_range(0, remaining))

	cuts.sort()

	# add boundaries
	cuts.insert(0, 0)
	cuts.append(remaining)

	# differences + 1
	var result := []
	for i in range(n):
		result.append(cuts[i + 1] - cuts[i] + 1)

	return result


static func random_positive_ints_sum_to_x_with_max(n: int, x: int, max_value: int) -> Array:
	if n <= 0 or x < n or x > n * max_value:
		return [] # impossible

	var result := []
	var remaining := x
	var remaining_slots := n

	for i in range(n):
		if remaining_slots == 1:
			result.append(remaining)
		else:
			var min_val = max(1, remaining - (remaining_slots - 1) * max_value)
			var max_val = min(max_value, remaining - (remaining_slots - 1) * 1)
			var val = randi_range(min_val, max_val)
			result.append(val)
			remaining -= val
		remaining_slots -= 1

	return result


static func random_nonnegative_ints_sum_to_x(n: int, x: int) -> Array:
	if n <= 0 or x < 0:
		return []

	if n == 1:
		return [x] # only one slot, take all

	var cuts := [0, x]
	for i in range(n - 1):
		cuts.append(randi_range(0, x))
	cuts.sort()

	var result := []
	for i in range(n):
		result.append(cuts[i + 1] - cuts[i])

	return result
