extends Control

@onready var but_win: Button = $ButWin
@onready var win_label: RichTextLabel = $WIN
@onready var panel_container: PanelContainer = $PanelContainer
@onready var reward_1: Label = $PanelContainer/VBoxContainer/HBoxContainer/Reward1
@onready var reward_2: Label = $PanelContainer/VBoxContainer/HBoxContainer2/Reward2




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI.manager.hide_overlay(UI.NAME.Arena)
	SoundManager.instance.play_sound("Level1", false)
	SoundManager.instance.play_sound("Level2", false)
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Winning", true, false)
	
	#for a in spawned_allies:
		#if a.has_node("AnimatedSprite2D") or a.has_method("animated_sprite"):
			## tentative safe play
			#if a.animated_sprite:
				#a.animated_sprite.play("default")
	
	await get_tree().create_timer(2.2).timeout
	
	SoundManager.instance.play_sound("Win", true, false)
	var lGo_Down: Vector2 = Vector2(0,440)
	var lTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	lTween.tween_property(but_win, "position", but_win.position + lGo_Down, 0.5)
	lTween.tween_property(panel_container, "position", panel_container.position + lGo_Down, 0.5)
	lTween.tween_property(win_label, "position", win_label.position + lGo_Down, 0.5)

	#reward_1.text = str(level_reward1) + "X"
	#reward_2.text = str(level_reward2) + "X"
	#if level_reward2 < 1:
		#$ControlWin/PanelContainer/VBoxContainer/HBoxContainer2.hide()
		#selected_special = Cookie.pick_random_special()
		#special_texture.texture = Cookie.type_sprite(selected_special)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_but_win_pressed() -> void:
	var tavern = get_parent().get_child(0)
	SoundManager.instance.play_sound("Win", false)
	SoundManager.instance.play_sound("Tavern", true, false)
	tavern.show()
	tavern.get_node("Camera2D").enabled = true
	tavern.get_node("AnimationPlayer").play("RESET")

	#var reward = { Cookie.TYPE.Normal: level_reward1, selected_special: level_reward2 }
	#tavern.update_after_victory(player_party, reward)
	queue_free()
