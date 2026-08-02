extends CanvasLayer

class_name UI
static var manager: UIManager

## If game isn't pixel art consider 1280×720 resolution under:
## if it is pixel art consider, from more to less detail =960x540, 640x360, 480x270, 320x10
## Project Settings > enable advanced mode > viewport


func _ready() -> void:
	var canvas_layer = $"."
	manager = UIManager.new(canvas_layer)
	manager.invoke_ui(UIManager.UI.MAIN_MENU)

	#Pass the general shader to the setting autoload
	Settings.register_shader($"../ShaderOverlay/ColorRect".material)
