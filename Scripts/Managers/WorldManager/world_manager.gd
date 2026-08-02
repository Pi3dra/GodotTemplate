# UIManager.gd
extends Node

class_name WorldManager

##TODO: Documents this

## This is where the user should add their UIs mapped to their corresponding UID
enum WORLDS { MAIN_WORLD }

const WORLD_PATHS = {
	WORLDS.MAIN_WORLD: "uid://b8eubejy2jhw2",
}

const PRELOADED_WORLDS = {
}

var _world_stack: Array[WorldManager.WORLDS] = []
var _root_node: Node
var _active_world: World

signal world_created(key: WorldManager.WORLDS)
signal world_removed(key: WorldManager.WORLDS)


func _init(root: Node):
	_root_node = root


## Searches first if the world is preloaded,
func _get_world(key: WorldManager.WORLDS) -> PackedScene:
	if PRELOADED_WORLDS.has(key):
		return PRELOADED_WORLDS.get(key)
	return load(WORLD_PATHS.get(key))


## Returns a positive integer indicating the position on stack
## if the world is on the stack, returns -1 otherwise
func is_on_stack(key: WorldManager.WORLDS) -> int:
	return _world_stack.find(key)


func is_active(key: WorldManager.WORLDS) -> bool:
	return _active_world.key == key


func pop_world():
	if _world_stack.is_empty():
		push_error("Triying to pop a previous, non existing world")

	#Remove current world
	_world_stack.pop_at(0)

	_active_world.on_world_exit()
	_active_world.queue_free()
	world_removed.emit()

	# Get previous world to instantiate
	var previous = _world_stack.pop_at(0)
	push_world(previous)


func push_world(key: WorldManager.WORLDS):
	var world_scene: PackedScene = _get_world(key)

	_active_world = world_scene.instantiate()
	_active_world.key = key
	_world_stack.push_front(key)
	_root_node.add_child(_active_world)

	world_created.emit(key)
	_active_world.on_world_enter()
