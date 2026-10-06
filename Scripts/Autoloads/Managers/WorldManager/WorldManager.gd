extends Node
## @experimental
## Quick and dirty autoload manager for Node2D Worlds, very similar to UIManager
## Keeps a stack and one can easily switch between worlds.
##
## This manager lacks some important features and will be updated in the future, mainly
## a lack of connection to Observable data

enum WORLDS { MAIN_WORLD }

const WORLD_PATHS = {
	WORLDS.MAIN_WORLD: "uid://b8eubejy2jhw2",
}
const PRELOADED_WORLDS = {}

signal world_created(key: WorldManager.WORLDS)
signal world_removed(key: WorldManager.WORLDS)

var root_node: Node
var _world_stack: Array[WorldManager.WORLDS] = [] # index 0 = current
var _active_world: World


func push_world(key: WorldManager.WORLDS) -> void:
	_replace_active(key)
	_world_stack.push_front(key)


func pop_world() -> void:
	if _world_stack.size() < 2:
		push_error("No previous world to return to")
		return
	_world_stack.pop_front()
	_replace_active(_world_stack.front())


## Returns the stack index, or -1 if the world isn't on the stack (0 = current).
func is_on_stack(key: WorldManager.WORLDS) -> int:
	return _world_stack.find(key)


func is_active(key: WorldManager.WORLDS) -> bool:
	return is_instance_valid(_active_world) and _active_world.key == key


func _replace_active(key: WorldManager.WORLDS) -> void:
	if root_node == null:
		push_error("WorldManager.root_node is not set")
		return

	var scene := _get_world(key)
	if scene == null:
		push_error("Unknown world: %s" % key)
		return

	if is_instance_valid(_active_world):
		var old_key := _active_world.key
		_active_world.on_world_exit()
		_active_world.queue_free()
		world_removed.emit(old_key)

	_active_world = scene.instantiate() as World
	_active_world.key = key
	root_node.add_child(_active_world)
	world_created.emit(key)


func _get_world(key: WorldManager.WORLDS) -> PackedScene:
	if PRELOADED_WORLDS.has(key):
		return PRELOADED_WORLDS[key]
	if WORLD_PATHS.has(key):
		return load(WORLD_PATHS[key]) as PackedScene
	return null
