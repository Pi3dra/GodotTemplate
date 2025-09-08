extends CanvasLayer

class_name UI

enum NAME { Merchant, CookieSelection, LevelSelection, Arena, Tutorial, Intro}

var key_to_path : Dictionary[NAME,String] = {
	NAME.Merchant : "uid://duf7bdfx04xnu",
	NAME.LevelSelection : "uid://wn0rp33fbpef",
	NAME.CookieSelection : "uid://cgftnhlkpkt4h",
	NAME.Arena : "uid://dpnhc72tu6qee",
	NAME.Tutorial : "uid://blkj8daistf6e",
	NAME.Intro : "uid://sfxssv6d0hly"
}

static var manager : UIManager
static var instance 

const GAME_SCENE = preload("uid://xy0wonkog4ns")

func _ready() -> void:
	instance = self
	manager = UIManager.new()
	manager.init_manager(key_to_path, self)
	UI.manager.call_overlay(NAME.Intro,self)
	UI.manager.connect_to_caller(NAME.Intro, {"beginning_finished":after_ready})

func after_ready():
	var game = GAME_SCENE.instantiate()
	Main.instance.add_child(game)
	SoundManager.instance.play_sound("Tavern", true, false)
