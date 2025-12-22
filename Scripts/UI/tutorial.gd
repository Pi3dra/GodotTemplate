extends Control

class_name Tutorial

static var instance
enum TUTORIALS { TAVERN, COMBAT }
var current_tutorial: TUTORIALS

var full_text := ""

@onready var label = $Speech
@onready var arrow_1: TextureRect = $Arrow1
@onready var arrow_2: TextureRect = $Arrow2
@onready var arrow_3: TextureRect = $Arrow3
@onready var arrow_4: TextureRect = $Arrow4

@onready var arrows: Array = [arrow_1, arrow_2, arrow_3, arrow_4]

var current_text_line: int = 0
var tween: Tween


func _ready():
	instance = self
	hide_arrows()
	current_tutorial = Globals.current_tutorial
	if current_tutorial == TUTORIALS.COMBAT:
		hide()
	match current_tutorial:
		TUTORIALS.COMBAT:
			$Label.text = "TRAINER"
		TUTORIALS.TAVERN:
			$Label.text = "INNKEEPER"

	label.text = ""
	full_text = get_dialog()
	update()


func update():
	tween = create_tween()
	for i in range(full_text.length()):
		tween.parallel().tween_callback(Callable(self, "_show_char").bind(i)).set_delay(0.05 * i)


func _show_char(i):
	label.text += full_text[i]


func hide_arrows():
	for arrow in arrows:
		arrow.hide()


#TODO This could easily be translated into resources
func get_dialog():
	var dialog: String = ""
	match current_tutorial:
		TUTORIALS.TAVERN:
			match current_text_line:
				0:
					dialog = "Hello! I'm the Inkeeper, welcome to my tavern, I can sell you powerful cookies
					and teach you about their hidden powers."
					hide_arrows()
					arrow_1.show()
					_animate_arrow(arrow_1)
				1:
					dialog = "This is the quest board, here you can select quests to do, and prepare your supplies."
					hide_arrows()
					arrow_2.show()
					_animate_arrow(arrow_2)
				2:
					dialog = "Once you are ready to battle, you can leave."
					hide_arrows()
					arrow_3.show()
					_animate_arrow(arrow_3)
				3:
					dialog = "I STRONGLY recommend you to see our knight here to train yourself first"
					hide_arrows()
					arrow_4.show()
					_animate_arrow(arrow_4)
				4:
					dialog = "Also, people in the tavern might be interested to join your party if you have enough cookies."
					hide_arrows()
				5:
					dialog = "end"
		TUTORIALS.COMBAT:
			match current_text_line:
				0:
					dialog = "Welcome to the training area, here you can test out different cookie combos and playstyles."
				1:
					dialog = "As it is your first time here i'll give you a tour of how combat works"
				2:
					dialog = "As you can see, Combat happens automatically. To turn odds into your favor you need to use your cookies"
				3:
					dialog = "You can click and drag cookies from the top bar, into either the Head side, or Tails side, You can always move them before flipping"
				4:
					dialog = "When hitting the FLIP button, all cookies will perform a flip, if they land correctly on the side where you placed them, your party will be greatly buffed"
				5:
					dialog = "Your normal cookies here, make your party deal 50% more damage for a single blow"
				6:
					dialog = "All cookies have special and different powers, visit the merchant to learn more"
				7:
					dialog = "Also if you kill enemies, they will drop cookies!"
				8:
					dialog = "You can come back at any time to test your party and your cookies!"
				9:
					dialog = "end"
	if dialog == "end":
		Globals.current_tutorial = null
		if current_tutorial == TUTORIALS.COMBAT:
			Globals.already_trained = true

		UI.manager.remove_overlay(UI.NAME.TUTORIAL)
	if dialog != "":
		current_text_line += 1
	return dialog


func _input(event):
	if event.is_action_pressed("skip"):
		label.text = ""
		full_text = get_dialog()
		if tween.is_running():
			tween.stop()
		update()


func _animate_arrow(arrow: TextureRect):
	var spawn_tween = create_tween().set_loops() # infinite loop
	var start_pos = arrow.position
	var offset = Vector2(0, -10) # how much it should float up

	spawn_tween.tween_property(arrow, "position", start_pos + offset, 0.5) \
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	spawn_tween.tween_property(arrow, "position", start_pos, 0.5) \
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# make the tween only update if the arrow is visible
	spawn_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	spawn_tween.connect("finished", func(): _animate_arrow(arrow)) # if not looping
