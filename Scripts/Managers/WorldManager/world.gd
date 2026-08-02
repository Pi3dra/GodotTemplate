# world.gd
extends Node2D

## Base class for all UI world scenes managed by UIManager.
## Attach this script (or a subclass) to the root Control node of any
## world scene so UIManager can instantiate, show, hide, and track it.
class_name World

var key: WorldManager.WORLDS

## Emitted when the world wants to be closed on user input, e.g. from a close button
## or Escape key. UIManager connects to this and decidec wether or not to close the world.
signal request_close(key: int)


## Called once, right after the world is instantiated.
## Use for one-time setup that shouldn't repeat on every show call.
## [b]Example:[/b]
## [codeblock]
## func _on_world_opened() -> void:
##     $AnimationPlayer.play("fade_in")
## [/codeblock]
func on_world_enter() -> void:
	pass


## Called every time show makes this world visible again. Use to
## refresh data that may have changed while the world was hidden.
## [b]Example:[/b]
## [codeblock]
## func _on_world_shown() -> void:
##     refresh_inventory_list()
## [/codeblock]
func on_world_exit() -> void:
	pass
