# My Godot Template

This is my v1 Template with a set of features that I find quite useful when making games, mostly quick prototypes for game jams.

## Features

### UI Manager
It's an autoload that opens, stacks, hides and frees `Interface` scenes under a single `CanvasLayer` root. It tracks two things: `active_interfaces` (key → instance) and `ui_stack` (navigation order, last = top).

##### Setup
1. Make a UI scene whose root script extends `Interface`.
2. Add a key to the `UI` enum and its scene UID to `UI_PATHS` inside UIManager.gd .
3. Set the root once, from the scene that owns the layer:

Then you have access to all the following functions:
```gdscript
UIManager.invoke_ui(UIManager.UI.SETTINGS)          # show or create, push on stack
UIManager.switch_ui(UIManager.UI.SETTINGS, UIManager.DisplayMode.HIDE)
UIManager.hide(key)      # hide, keep the instance, restore the one underneath
UIManager.remove(key)    # free it, restore the one underneath
UIManager.hide_all()     # no restore
UIManager.remove_all()   # no restore
UIManager.get_top_ui()            # UI.NONE if empty
UIManager.get_ui_instance(key)    # null (with error) if not active
```

The UIManager also emits a handful of useful signals: 
``` gdscript 
signal interface_shown(key: UI)
signal interface_hidden(key: UI)
signal interface_created(key: UI)
signal interface_removed(key: UI)
```

### World Manager
Same Idea as the UIManager, but for Node2D’s
#### Setup
1. Make a world scene whose root script extends `World`.
2. Add a key to `WORLDS` and its UID to `WORLD_PATHS`. Put it in `PRELOADED_WORLDS` too (with `preload`) if you want to skip the `load()` hitch.
3. Register the node that holds worlds, from the main scene:

And gain access to the following functions: 

```gdscript
WorldManager.push_world(WorldManager.WORLDS.MAIN_WORLD)  # replace the current world, remember the old one
WorldManager.pop_world()                                 # go back to the previous world
WorldManager.is_active(key)
WorldManager.is_on_stack(key)                            # index, or -1
```

### Settings Manager
This is an autoload, that owns a `SettingsData` resource, it applies each option to the engine, and persists everything into: `user://saves/settings.tres`
It also stores default settings which can be restored at anytime.

```gdscript
# One-time: the UI root hands over the shader overlay
Settings.register_shader(overlay_material)

# Change and read options
Settings.set_option(Settings.OPTION.MUSIC, 0.5)
var v = Settings.get_value(Settings.OPTION.MUSIC)

# Persist / reset
Settings.save()
Settings.reset_to_default([], true)   # reset everything
```

#### Adding new configurations
**A new configuration:** add it to `OPTION`, to `SettingsData`, and to both `match` blocks (`get_value`, `set_option`). `apply_all_settings` picks it up automatically.

**A rebindable action:**
1. Add the action in Project Settings → Input Map.
2. Add a `Button` under `Controllers/KeyBinds/Inputs` whose **name is exactly the action name**.

No script changes are needed. Actions starting with `ui_` are skipped in both saving and collision checks.

### Sound Manager
An autoload that loads every sound from two folders at startup, then plays them through a fixed pool of `AudioStreamPlayer`s with a per-sound polyphony cap. Sounds are addressed by file name without the extension.

#### Features

| Area           | What it does                                                                                                                                               |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Library        | Scans `Assets/Audio/Music` (bus `Music`) and `Assets/Audio/SFX` (bus `SFX`) for `.ogg`, `.mp3` and `.wav`, and wraps each in a `SoundData`                 |
| Pooling        | 16 players are created up front and reused. When all are busy, the first one is stolen                                                                     |
| Polyphony      | A sound can't have more than `default_max_polyphony` (8) voices at once, unless its `SoundData.max_polyphony` says otherwise. Extra requests return `null` |
| Global control | `stop_all()`, `pause_all()`, `resume_all()`                                                                                                                |
*polyphony refers to how many copies of the same sound can play at once

#### Usage

```gdscript
SoundManager.play("hit")                          # fire and forget
var p := SoundManager.play("theme", -6.0, 1.0, true)  # looping music, keep the player to stop it later
SoundManager.play_random_pitch("footstep", 0.9, 1.1)
SoundManager.pause_all()
```

To add a sound, drop the file in one of the two folders. The file name is the key, and the bus comes from the folder.

### DevConsole
My take on a dev console! heavily inspired by [this video](https://www.youtube.com/watch?v=io7OiwNtGFE).
It runs as an autoload, and the default key to open it is F1 (This is obviously configurable)

A `CanvasLayer` you toggle with a hotkey. You type GDScript expressions, and they run against the current **context**, a node you registered. It can pause the game while open.

#### Features

|Area|What it does|
|---|---|
|Expressions|Any GDScript expression runs through `Expression` with the current context as base, so `health.value = 10` or `spawn_enemy(3)` just works|
|Contexts|Nodes registered with `add_context(name, node)`. `ls c` lists them, `cd name` switches, and the prompt shows the active one|
|Introspection|`ls` lists signals, variables, methods and contexts of the current context's script. `ls m`, `ls v`, `ls s` and `ls c` filter by kind|
|Autocomplete|Tab completes from the context's script members, and repeated Tab cycles through the matches|
|History|Up/down arrows walk previous commands, without consecutive duplicates|
|Output|Colored, BBCode output in a `RichTextLabel`, with `clear` to wipe it|
|Customization|Prompt symbol and all colors are exported. `hide_private` hides `_`-prefixed members, and `pause_when_shown` pauses the tree while open|

#### Usage

```gdscript
# One-time: expose a node
DevConsole.add_context("world", world_manager)
DevConsole.add_context("player", player_node)
```

In the console:

```
~ ls c            # list contexts
~ cd player        # switch context
~ ls m             # list its methods
~ take_damage(5)   # call a method directly
~ health           # print a variable
~ cd console       # back to the console itself
```


### Effect Library
A small but powerfully composable effect library.
The main point for me is to gather a library of small and often reused effects, that I make between game jams.
When I mean an effect it can be anything, spawning sprites, particles, tweens, shaders, sound etc etc.

Concretely an `Effect` is a reusable configuration (duration, strength, shader path). Each `play()` creates an `EffectContext`, which holds the running state (tween, spawned nodes, signals), and an autoload `EffectManager` tracks the running contexts per node.

| Piece                      | Role                                                                                    |
| -------------------------- | --------------------------------------------------------------------------------------- |
| `Effect`                   | Stateless description of what to do. One instance can play on many nodes at once.       |
| `EffectContext`            | One running play: target, scratch `data`, tween, timer, `finished` and `ended` signals. |
| `EffectManager` (autoload) | Tracks contexts per node and name, and provides stop, pause and resume commands.        |
| Composites                 | `SequenceEffect`, `ParallelEffect`, `RepeatEffect` combine other effects.               |
| Built-in effects           | Fade, Shake, Shader, Sound, Particle (animated sprite), TextParticle (floating text).   |

| Area                   | What it does                                                                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Name-based replacement | Playing an effect whose name is already running on that node cancels the old one. The default name is the class name, and `play(node, &"custom")` overrides it.    |
| Commands               | `stop(node, name)`, `stop_all(node)`, `pause`, `resume`, `pause_all`, `resume_all`, `is_playing`, `stop_everything()`                                              |
| Auto cleanup           | When a node leaves the tree, its effects are cancelled. `_cleanup` undoes side effects on both finish and cancel (removes materials, frees sprites, stops sounds). |
| Flexible endings       | A context can end on a tween, a timer, a signal, or whichever comes first.                                                                                         |
| Pause hooks            | `_on_pause` and `_on_resume` let effects pause what they own, such as audio players and sprites.                                                                   |
| Chaining               | `on_finished` fires on normal completion only, never on cancel. If the effect already finished, it runs immediately.                                               |
#### Usage

```gdscript
# Play and react
Effect.fade(4.0, true).play(label).on_finished(func(): label.text = "")

# Combine
Effect.shake(10.0).with(SoundEffect.new(&"hit")).play(button)
Effect.fade(1.0, true).then(Effect.shake(6.0)).play(panel)

# Reuse one effect on many nodes
var shake := ShakeEffect.new(10.0)
for enemy in enemies:
	shake.play(enemy)

# Control
EffectManager.stop(button, &"ShakeEffect")
EffectManager.stop_all(button)
EffectManager.pause_all(button)
```

### Observables (Experimental)

This is an attempt to make it easier for UI to keep track of changes of the data, the idea is to define a set of observable variables, point a View model to it, which will automatically hook to it, and receive signals when any of these variables are changed. (I know Resource already has something like this, but the goal is to make it more powerful/easier to use)

## Upcoming Features (By order of priority)

#### Credit Screen
- I often use free assets in game jams, I think it would really be cool to do a credit screen thanking them all, just scanning a source.txt file

#### Misc
- Propose multiple light to heavy versions, as well as cellphone and pc presets.
	- light - has no assets, no plugins, no test nodes, no big folder structure, no default tscn’s, lesser functions
	- medium - basic assets, default theme, some plugins, all functionalities except experimental
	- heavy - all assets, all resources, all plugins, all functionalities
	- tasty - The Template adapted to my taste, with some functional changes. may not be compatible with previous versions
-  Make the existings UIs a bit nicer
- Add plugins and update them
- Propose a Framework for doing transitions for the following managers: (Sound, UI, World?)
- Adding way more assets, shaders, transitions etc etc. Maybe some common UI Displays

#### World and UI Manager
- Add a context manager, that could help to instantiate way bigger and more complex scenes, while handling dependency injections, signal linking, data loading/Initialization (This might be overkill for small game jams, but could be useful in a heavier version of the template) Inspired by this: https://www.youtube.com/watch?v=HkjOE4FbrXo&t=750s

- Add async loading for heavier worlds
- Quick World Reloading

#### Effect Library
- Make the effects agnostic from global managers, so they can be previewed in the editor with @tool, the idea is to do this in such a way that the effects would work in the editor, but use the managers in game


#### Dev Console
The dev console, could have a lot of features, but I still have to test it’s usefulness:
 - help command which shows the custom commands and their descriptions
 - printing history and quickly executing old commands, as well as storing commands in a logfile
 - adding possibility to add nested contexts? or automatically adding context given a root
 - time controls, pause timescale etc
 - reload
 - find and tree inspection
 - basic function chaining stuff like && | etc (don't know if chaining is easily possible)
 - Custom parsing for function calls: myfunc a b c instead of myfunc(a,b,c)
 - Watch command for keeping track of variables 
 - Add support for multiple panes? 

I was also thinking in maybe porting this to a C# or a Rust version, but It’s not intended for the near future.
