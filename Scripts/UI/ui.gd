extends CanvasLayer

class_name UI

enum NAME {
	MERCHANT,
	COOKIE_SELECTION,
	LEVEL_SELECTION,
	ARENA,
	TUTORIAL,
	INTRO,
	WIN_SCREEN,
	GAME_OVER,
}

var key_to_path: Dictionary[NAME, String] = {
	NAME.MERCHANT: "uid://duf7bdfx04xnu",
	NAME.LEVEL_SELECTION: "uid://wn0rp33fbpef",
	NAME.COOKIE_SELECTION: "uid://cgftnhlkpkt4h",
	NAME.ARENA: "uid://dpnhc72tu6qee",
	NAME.TUTORIAL: "uid://blkj8daistf6e",
	NAME.INTRO: "uid://sfxssv6d0hly",
	NAME.WIN_SCREEN: "uid://1cnkhmktcngn",
	NAME.GAME_OVER: "uid://b43j4xlbwfwoo",
}

static var manager: UIManager
static var instance

const GAME_SCENE = preload("uid://xy0wonkog4ns")


func _ready() -> void:
	instance = self
	manager = UIManager.new()
	manager.init_manager(key_to_path, self)

	UI.manager.call_overlay(NAME.INTRO, self)
	UI.manager.connect_to_caller(NAME.INTRO, { "beginning_finished": after_ready })


func after_ready():
	var game = GAME_SCENE.instantiate()
	Main.instance.add_child(game)
	SoundManager.instance.play_sound("Tavern", true, false)
