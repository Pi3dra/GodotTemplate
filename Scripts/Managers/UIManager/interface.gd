# interface.gd
extends Control
## Base class for all UI interface scenes managed by UIManager.
## Attach this script (or a subclass) to the root Control node of any
## interface scene so UIManager can instantiate, show, hide, and track it.
class_name Interface

var key : UIManager.UI

## Emitted when the interface wants to be closed on user input, e.g. from a close button
## or Escape key. UIManager connects to this and decidec wether or not to close the interface.
signal request_close(key: int)

## Called once, right after the interface is instantiated. 
## Use for one-time setup that shouldn't repeat on every show call.
## [b]Example:[/b]
## [codeblock]
## func _on_interface_opened() -> void:
##     $AnimationPlayer.play("fade_in")
## [/codeblock]
func on_interface_created() -> void:
	pass

## Called every time show makes this interface visible again. Use to
## refresh data that may have changed while the interface was hidden.
## [b]Example:[/b]
## [codeblock]
## func _on_interface_shown() -> void:
##     refresh_inventory_list()
## [/codeblock]
func on_interface_shown() -> void:
	pass

## Called when hiding this interface.
## Use to pause per-interface activity (timers, tweens, input focus) while
## it's off-screen but still alive in memory.
## [b]Example:[/b]
## [codeblock]
## func _on_interface_hidden() -> void:
##     $BlinkTimer.stop()
## [/codeblock]
func on_interface_hidden() -> void:
	pass

## Called right before the interface's node is queue_free()'d. 
##Use for final cleanup: saving state, disconnecting
## signals, stopping tweens that reference this node.
## [b]Example:[/b]
## [codeblock]
## func _on_interface_closing() -> void:
##     save_scroll_position()
## [/codeblock]
func on_interface_closing() -> void:
	pass


	
	
