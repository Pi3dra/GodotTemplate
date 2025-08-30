extends Control

class_name tutorial

enum TUTORIALS {Tavern, Combat}

var current_tutorial : TUTORIALS 

var full_text := ""

@onready var label = $Speech
@onready var arrow_1: TextureRect = $Arrow1
@onready var arrow_2: TextureRect = $Arrow2
@onready var arrow_3: TextureRect = $Arrow3
@onready var arrows : Array = [arrow_1, arrow_2, arrow_3]

var current_text_line : int = 0
var tween : Tween

func _ready():
	hide_arrows()
	current_tutorial = Globals.current_tutorial
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

func get_dialog():
	var dialog : String = ""
	match current_tutorial:
		TUTORIALS.Tavern:
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
					dialog = "Also, people in the tavern might be interested to join your party if you have enough cookies."
					hide_arrows()
				4:
					dialog = "end"
		_:
			dialog = ""
			
	if dialog == "end" : queue_free()
	if dialog != "": current_text_line += 1
	return dialog
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			label.text = ""
			full_text = get_dialog()
			if tween.is_running():
				tween.stop()
			update()
			

func _animate_arrow(arrow: TextureRect):
	var tween = create_tween().set_loops() # infinite loop
	var start_pos = arrow.position
	var offset = Vector2(0, -10) # how much it should float up

	tween.tween_property(arrow, "position", start_pos + offset, 0.5) \
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(arrow, "position", start_pos, 0.5) \
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# make the tween only update if the arrow is visible
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.connect("finished", func(): _animate_arrow(arrow)) # if not looping
