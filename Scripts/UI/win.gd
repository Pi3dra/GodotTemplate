extends Control

@onready var but_win: Button = $ButWin
@onready var win_label: RichTextLabel = $WIN
@onready var panel_container: PanelContainer = $PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI.manager.hide_overlay(UI.NAME.ARENA)
	var rewards = UI.manager.get_data(UI.NAME.WIN_SCREEN)

	for cookie_type in rewards.keys():
		if rewards[cookie_type] > 0:
			var cookie_data = Globals.get_cookie_data(cookie_type)
			var richlabel = RichTextLabel.new()
			richlabel.bbcode_enabled = true
			richlabel.fit_content = true
			richlabel.scroll_active = false
			richlabel.clip_contents = false
			richlabel.autowrap_mode = TextServer.AUTOWRAP_OFF

			# Register the cookie texture as an inline image
			richlabel.add_image(cookie_data.head_texture)
			richlabel.append_text("x%d  " % rewards[cookie_type])
			$PanelContainer/VBoxContainer.add_child(richlabel)

	SoundManager.instance.play_sound("Level1", false)
	SoundManager.instance.play_sound("Level2", false)
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Winning", true, false)

	await get_tree().create_timer(2.2).timeout

	SoundManager.instance.play_sound("Win", true, false)
	var go_down: Vector2 = Vector2(0, 550)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(but_win, "position", but_win.position + go_down, 0.5)
	tween.tween_property(panel_container, "position", panel_container.position + go_down, 0.5)
	tween.tween_property(win_label, "position", win_label.position + go_down, 0.5)


signal switch_to_tavern


func _on_but_win_pressed() -> void:
	SoundManager.instance.play_sound("Win", false)
	SoundManager.instance.play_sound("Tavern", true, false)
	emit_signal("switch_to_tavern")
	UI.manager.remove_overlay(UI.NAME.ARENA)
	UI.manager.remove_overlay(UI.NAME.WIN_SCREEN)
