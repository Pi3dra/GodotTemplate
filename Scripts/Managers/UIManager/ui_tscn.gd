extends CanvasLayer
class_name UI
static var manager: UIManager

## If game isn't pixel art consider 1280×720 resolution under:
## Project Settings > enable advanced mode > viewport

func _ready() -> void:
	var canvas_layer = $"."
	manager = UIManager.new(canvas_layer)
	manager.invoke_ui(UIManager.UI.MAIN_MENU)
