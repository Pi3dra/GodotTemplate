class_name UIManager
"""
An abstraction layer for handling data transmission between UI and different scenes,
The Idea here is to provide easy tooling to:
- Transfer data on initialization
- make signal hookup easier
"""

var overlay_scenes : Dictionary = {} #[Enum, Overlay]
var active_overlays : Dictionary = {} # [Enum,Overlay]

var root_node : CanvasLayer 


func init_manager(key_to_path : Dictionary, canvas_layer : Node):
	for ui_key in key_to_path.keys():
		var overlay = Overlay.new(ui_key, key_to_path[ui_key])
		overlay_scenes.set(ui_key, overlay)
	root_node = canvas_layer

func call_overlay(key : int, caller : Node, data : Dictionary = {}  ):
	if active_overlays.has(key):
		show_overlay(key)
		return

	var caller_obj : Caller = Caller.new(caller)
	var ui_obj : Overlay = overlay_scenes.get(key)
	var ui_instance = ui_obj.instantiate_ui(caller_obj, data) 
	
	active_overlays.set(key, ui_obj)
	root_node.add_child(ui_instance)

func connect_to_caller(key : int, from_ui : Dictionary):
	_modify_signals(key, {}, from_ui)

func connect_to_ui(key :int, from_caller : Dictionary):
	_modify_signals(key, from_caller, {})

#TODO: split this into , connect_to_ui and connect_to_caller
func connect_signals(key: int, from_caller_signals: Dictionary = {}, from_ui_signals: Dictionary = {}):
	"""
	The overlay will conenct to the [String, Callable] key value pairs in from_caller_signals
	where: 
		- String is the name of the caller signal
		- Callable is the function of the overlay to be called
	
	The caller will be connected to the [String, Callable] key value pairs in from_ui_signals
	where:
		- String is the name of the UI signal
		- Callable is the method of the callable to be executed
	"""
	_modify_signals(key, from_caller_signals, from_ui_signals, true)

func disconnect_signals(key: int, to_ui_signals: Dictionary = {}, from_ui_signals: Dictionary = {}):
	_modify_signals(key, to_ui_signals, from_ui_signals, false)
	


func _modify_signals(key: int, from_caller_signals: Dictionary = {}, from_ui_signals: Dictionary = {}, connect: bool = true):
	if from_caller_signals.is_empty() and from_ui_signals.is_empty():
		push_warning("No signals provided")
		
	if not active_overlays.has(key):
		push_error("Trying to modify signals for an Overlay that's not instantiated")
		return
		
	var overlay: Overlay = active_overlays[key]
	var caller: Caller = overlay.caller
	
	if not from_caller_signals.is_empty():
		for signame in from_caller_signals.keys():
			if connect:
				caller.connect_signal(signame, from_caller_signals[signame])
			else:
				caller.disconnect_signal(signame, from_caller_signals[signame])
				
	if not from_ui_signals.is_empty():
		for signame in from_ui_signals.keys():
			if connect:
				overlay.connect_signal(signame, from_ui_signals[signame])
			else:
				overlay.disconnect_signal(signame, from_ui_signals[signame])



func get_ui_instance(key : int) -> Node:
	push_warning("This is ok for quick prototyping, better use signals instead")
	if !active_overlays.has(key):
		push_error("can't get instance of inactive UI")
		return
	return active_overlays[key].instance
	
func get_caller_instance(key : int) -> Node:
	push_warning("This is ok for quick prototyping, better use signals instead")
	if !active_overlays.has(key):
		push_error("can't get instance of inactive UI")
		return
	return active_overlays[key].caller.instance



func hide_overlay(key : int ):
	if !active_overlays.has(key):
		push_error("Can't hide an unactive overlay")
		return
	active_overlays[key].hide()
	
func show_overlay(key : int ):
	if !active_overlays.has(key):
		push_error("Can't show an unactive overlay")
		return
	active_overlays[key].show()


func remove_overlay(key : int):
	"""
	In order it does:
		- Disconnects all signals
		- Queue_frees the ui instance
		- removes the Overlay Object from the active_overlays dictionnary
		- Clears the data from the Overlay Object
	"""
	var overlay : Overlay
	
	if active_overlays.has(key):
		overlay = active_overlays[key]
	else:
		push_error("Triying to remove a non active UI")
	
	var caller : Caller = overlay.caller
	
	# TODO disconnect signals here
	if !caller.from_ui_signals.is_empty() or !overlay.from_caller_signals.is_empty():
		disconnect_signals(key, caller.from_ui_signals, overlay.from_caller_signals,)
	overlay.instance.queue_free()
	overlay.clear()
	active_overlays.erase(key)

func get_data(key):
	if active_overlays.has(key):
		return active_overlays[key].data
	else:
		push_error("Triying to retrieve data from an unactive overlay")
		return {}

class Overlay:
	var name : int 
	var tscn_path 
	var instance : Node 
	var caller : Caller
	var data : Dictionary
	var from_caller_signals : Dictionary[String,Callable]
	
	var hidden : bool 
	var dirty : bool #Indicates wether or not the data on the UI has changed from it's orig
	
	func _init(overlay_name : int, path : String):
		name = overlay_name
		tscn_path = path
	
	func clear():
		instance = null
		caller = null
		data = {}
		hidden = false
		
	func instantiate_ui(instance_caller : Caller, init_data : Dictionary = {}) -> Node:
		"""
		Instantiates the UI tscn, and populates shared data
		"""
		var ui = load(tscn_path)
		var ui_instance = ui.instantiate()
		
		instance = ui_instance
		data = init_data
		caller = instance_caller
		
		return ui_instance
		
		
	func connect_signal(signal_name : String, function : Callable):
		"""
		Connects Signal from overlay to caller method
		"""
		if not from_caller_signals.has(signal_name):
			instance.connect(signal_name, function)
			from_caller_signals.set(signal_name, function)
		
	func disconnect_signal(signal_name : String, function : Callable):
		"""
		Disonnects Signal from overlay to caller method
		"""
		if from_caller_signals.has(signal_name):
			instance.disconnect(signal_name, function)
			from_caller_signals.erase(signal_name)

	func hide():
		if !hidden:
			instance.hide()
			hidden = true
		
	func show():
		if hidden:
			instance.show()
			hidden = false

class Caller:
	"""
	Represents the Caller of an Overlay.
	Aka the Node displayed below the UI.
	"""
	var name : String
	var instance : Node
	var from_ui_signals : Dictionary

	func _init(caller_instance : Node ):
		instance = caller_instance
		
	func connect_signal(signal_name : String, function : Callable):
		"""
		Connects Signal from caller to ui method
		"""
		if not from_ui_signals.has(signal_name):
			instance.connect(signal_name, function)
			from_ui_signals.set(signal_name, function)
		
	func disconnect_signal(signal_name : String, function : Callable):
		""" 
		Disonnects Signal from caller to ui method
		"""
		if from_ui_signals.has(signal_name):
			instance.disconnect(signal_name, function)
			from_ui_signals.erase(signal_name)
			

"""
Possible Pain points:
	

1. Overlay lifecycle events

on_overlay_opened and on_overlay_closed signals in UIManager, so callers can react globally.

Useful for analytics, debugging, or global UI coordination.


2. Stacked overlays

Right now, multiple overlays can coexist, but there’s no priority or z-order management.

Add an overlay stack so you can push_overlay and pop_overlay with proper layering.


3. Modal vs. non-modal overlays

Sometimes you want an overlay to block interaction with the caller (modal), sometimes not.

Add a modal: bool flag to Overlay.


4. Overlay re-use / caching

Currently, overlays are destroyed (queue_free) on remove_overlay.

Add an option to cache and re-use overlays (e.g., keep them hidden instead of freeing).


5. Global data passing

Right now, data is only passed on instantiation.

Add update_overlay_data(key, data: Dictionary) so overlays can refresh without reinstantiation.




"""
