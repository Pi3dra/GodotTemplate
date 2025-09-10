extends BoxContainer

var button_cookies : Dictionary[Button,Cookie] = {}

func _ready() -> void:
	pass

#func _on_mouse_entered(pButton: Button = null) -> void:
	#Engine.time_scale = 0.4
	#AudioServer.playback_speed_scale = 0.4
	#if pButton != null:
		#pButton.pivot_offset = pButton.size/2
		#var lTween = create_tween()
		#lTween.tween_property(pButton, "scale", Vector2.ONE*2, 0.1)
		##TODO rajouter la fiche info des effets du cookie
#
#
#func _on_mouse_exited(pButton: Button = null) -> void:
	#Engine.time_scale = 1
	#AudioServer.playback_speed_scale = 1
	#if pButton != null:
		#var lTween = create_tween()
		#lTween.tween_property(pButton, "scale", Vector2.ONE*1, 0.1)
		##TODO enlever la fiche info des effets du cookie
